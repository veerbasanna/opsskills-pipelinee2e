pipeline {
    agent { label 'awslinuxgit' }

    options {
        timestamps()
    }

    environment {
        GIT_REPO = 'https://github.com/veerbasanna/opsskills-pipelinee2e.git'
        BRANCH   = 'main'
        PIPX_BIN = '/home/ubuntu/.local/bin'
    }

    stages {

        stage('Checkout repo') {
            steps {
                git branch: "${BRANCH}",
                    url: "${GIT_REPO}",
                    credentialsId: '85833247-5a5e-4217-af37-e4b6332f6f97'
            }
        }

        stage('Prepare tools') {
            steps {
                echo 'Installing required tools on Ubuntu 24.04'
                sh '''
                    set -e
                    sudo apt-get update -y
                    sudo apt-get install -y \
                        python3 \
                        python3-pip \
                        pipx \
                        cmake \
                        build-essential \
                        curl

                    pipx ensurepath

                    if ! command -v cmakelint >/dev/null 2>&1; then
                        pipx install cmakelint
                    fi
                '''
            }
        }

        stage('Lint') {
            steps {
                echo 'Running CMake lint checks'
                sh '''
                    set -e
                    export PATH="$PATH:/home/ubuntu/.local/bin"

                    if [ ! -f CMakeLists.txt ]; then
                        echo "CMakeLists.txt not found" > lint_report.txt
                        exit 0
                    fi

                    cmakelint --version
                    cmakelint CMakeLists.txt > lint_report.txt 2>&1 || true
                    cat lint_report.txt
                '''
            }
            post {
                always {
                    archiveArtifacts artifacts: 'lint_report.txt', fingerprint: true
                }
            }
        }

        stage('Build') {
            steps {
                echo 'Building project using CMake'
                sh '''
                    set -e

                    if [ ! -f CMakeLists.txt ]; then
                        echo "CMakeLists.txt not found!"
                        exit 1
                    fi

                    rm -rf build
                    mkdir build
                    cd build
                    cmake -DCMAKE_EXPORT_COMPILE_COMMANDS=ON ..
                    make -j$(nproc)
                    cp compile_commands.json ..
                '''
            }
        }

        stage('Unit Tests') {
            steps {
                sh '''
                    set -e
                    cd build
                    ctest --output-on-failure \
                          --test-output-junit test-results.xml || true
                '''
            }
            post {
                always {
                    junit allowEmptyResults: true,
                          testResults: 'build/test-results.xml'
                }
            }
        }
    }
}

