#!groovy

def tryStep(String message, Closure block, Closure tearDown = null) {
    try {
        block()
    }
    catch (Throwable t) {
        slackSend message: "${env.JOB_NAME}: ${message} failure ${env.BUILD_URL}", channel: '#ci-channel', color: 'danger'
        throw t
    }
    finally {
        if (tearDown) {
            tearDown()
        }
    }
}

node {
    stage("Checkout") {
        checkout scm 
    }

    stage("Build API image") {
        tryStep "build", {
           sh "git checkout schema-repos-reorg-ds-269"
            docker.withRegistry("${DOCKER_REGISTRY_HOST}",'docker_registry_auth') {
            def image = docker.build("datapunt/dataservices/publish-static:${env.BUILD_NUMBER}", "src")
            image.push()
            image.push("acceptance")
            image.push("production")
            }
        }
    }
}

