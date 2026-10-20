"""Run with GRADLE_BIN=/path/to/gradle JAVA_HOME=/path/to/jdk python3 tests/test_jdtls_gradle.py."""

import os
from pathlib import Path
import shutil
import subprocess
import tempfile
import unittest


GRADLE = os.environ.get("GRADLE_BIN") or shutil.which("gradle")
INIT_SCRIPT = Path(__file__).resolve().parents[1] / "gradle/jdtls.init.gradle"

VERIFY_SCRIPT = """
import org.gradle.plugins.ide.eclipse.model.Classpath
import org.gradle.plugins.ide.eclipse.model.Output
import org.gradle.plugins.ide.eclipse.model.ProjectDependency
import org.gradle.plugins.ide.eclipse.model.SourceFolder

gradle.projectsEvaluated {
    allprojects { project ->
        if (project.plugins.hasPlugin('java')) {
            project.plugins.apply('eclipse')
        }
    }
    rootProject.tasks.register('verifyJdtlsOutput') {
        doLast {
            int projectDependencies = 0
            int sourceFolders = 0
            gradle.rootProject.allprojects.findAll { it.plugins.hasPlugin('java') }.each { project ->
                def eclipse = project.extensions.getByName('eclipse')
                def links = eclipse.project.linkedResources.findAll { it.name == 'bin' }
                assert links.size() == 1
                assert links.first().location == project.file('build/jdtls').absolutePath

                // JDTLS queries both full and project-dependencies-only models.
                [false, true].each { dependenciesOnly ->
                    eclipse.classpath.projectDependenciesOnly = dependenciesOnly
                    def classpath = new Classpath(eclipse.classpath.fileReferenceFactory)
                    eclipse.classpath.mergeXmlClasspath(classpath)
                    classpath.entries.each { entry ->
                        if (entry instanceof SourceFolder) {
                            sourceFolders++
                            assert entry.output == null || entry.output.startsWith('build/jdtls/')
                        } else if (entry instanceof ProjectDependency) {
                            projectDependencies++
                            assert entry.path == '/library'
                        } else if (entry instanceof Output) {
                            assert entry.path == 'build/jdtls/default'
                        }
                    }
                }
                assert !project.file('bin').exists()
            }
            assert sourceFolders > 0
            assert projectDependencies > 0
            println 'JDTLS_OUTPUT_VERIFIED'
        }
    }
}
"""

GROOVY_BUILD = """
subprojects {
    apply plugin: 'java-library'
    sourceSets {
        integrationTest {
            java.srcDir 'src/integrationTest/java'
            resources.srcDir 'src/integrationTest/resources'
        }
    }
}
project(':service') {
    dependencies { implementation project(':library') }
}
"""

KOTLIN_BUILD = """
subprojects {
    apply(plugin = "java-library")
    extensions.configure<JavaPluginExtension> {
        sourceSets.create("integrationTest")
    }
}
project(":service") {
    dependencies { add("implementation", project(":library")) }
}
"""


@unittest.skipUnless(GRADLE, "Set GRADLE_BIN to a local Gradle executable")
class JdtlsGradleOutputTest(unittest.TestCase):
    def setUp(self):
        base = Path(tempfile.gettempdir()) / "opencode"
        base.mkdir(parents=True, exist_ok=True)
        self.directory = tempfile.TemporaryDirectory(prefix="jdtls-gradle-test-", dir=base)
        self.addCleanup(self.directory.cleanup)
        self.root = Path(self.directory.name)
        self.write("settings.gradle", "rootProject.name = 'jdtls-output-test'\ninclude 'library', 'service'\n")
        self.write("build.gradle", GROOVY_BUILD)
        self.write("verify.init.gradle", VERIFY_SCRIPT)
        for module in ("library", "service"):
            for source_set in ("main", "test", "integrationTest"):
                for kind in ("java", "resources"):
                    (self.root / module / "src" / source_set / kind).mkdir(parents=True)

    def write(self, name, content):
        path = self.root / name
        path.parent.mkdir(parents=True, exist_ok=True)
        path.write_text(content)
        return path

    def run_gradle(self, expect_success=True):
        result = subprocess.run(
            [
                GRADLE, "--offline", "--console=plain", "--max-workers=2",
                "--init-script", str(INIT_SCRIPT),
                "--init-script", str(self.root / "verify.init.gradle"),
                "verifyJdtlsOutput",
            ],
            cwd=self.root,
            capture_output=True,
            text=True,
            timeout=120,
        )
        output = result.stdout + result.stderr
        if expect_success:
            self.assertEqual(result.returncode, 0, output)
            self.assertIn("JDTLS_OUTPUT_VERIFIED", output)
        else:
            self.assertNotEqual(result.returncode, 0, output)
        return output

    def test_groovy_multi_module_and_custom_source_sets(self):
        self.run_gradle()

    def test_kotlin_dsl_multi_module(self):
        (self.root / "build.gradle").unlink()
        self.write("build.gradle.kts", KOTLIN_BUILD)
        self.run_gradle()

    def test_eclipse_plugin_before_java_plugin(self):
        self.write("build.gradle", "subprojects { apply plugin: 'eclipse' }\n" + GROOVY_BUILD)
        self.run_gradle()

    def test_non_java_root_bin_is_not_changed(self):
        sentinel = self.write("bin/tool", "Existing non-Java tooling\n")
        self.run_gradle()
        self.assertEqual(sentinel.read_text(), "Existing non-Java tooling\n")

    def test_existing_java_bin_is_not_replaced(self):
        sentinel = self.write("library/bin/keep.txt", "Existing project data\n")
        output = self.run_gradle(expect_success=False)
        self.assertIn("existing files will not be replaced", output)
        self.assertEqual(sentinel.read_text(), "Existing project data\n")

    def test_existing_different_eclipse_link_is_not_replaced(self):
        self.write("build.gradle", """
subprojects {
    apply plugin: 'eclipse'
    eclipse.project.linkedResource(name: 'bin', type: '2', location: file('custom-output').absolutePath)
}
""" + GROOVY_BUILD)
        output = self.run_gradle(expect_success=False)
        self.assertIn("already defines a different Eclipse bin link", output)


if __name__ == "__main__":
    unittest.main(verbosity=2)
