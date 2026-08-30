# devkit shell functions

# Switch JDK version
# Usage: jdk 21, jdk 17, jdk 11, jdk 8
jdk() {
  local version=$1
  if [[ -z "$version" ]]; then
    echo "Usage: jdk <version>"
    echo "Available:"
    /usr/libexec/java_home -V 2>&1 | grep -E '^\s+\d' | sed 's/^  /  /'
    return 1
  fi
  export JAVA_HOME=$(/usr/libexec/java_home -v"$version")
  java -version
}

# -------------------------------------------------------------------
# Cloud helpers
# -------------------------------------------------------------------

# Switch AWS profile
# Usage: awsprofile staging, awsprofile prod
awsprofile() {
  if [[ -z "$1" ]]; then
    echo "Current: ${AWS_PROFILE:-default}"
    echo ""
    echo "Available profiles:"
    aws configure list-profiles 2>/dev/null
    return
  fi
  export AWS_PROFILE="$1"
  echo "AWS_PROFILE=$AWS_PROFILE"
}

# Switch gcloud project
# Usage: gproject my-project-id
gproject() {
  if [[ -z "$1" ]]; then
    echo "Current: $(gcloud config get-value project 2>/dev/null)"
    echo ""
    echo "Available projects:"
    gcloud projects list --format="table(projectId, name)" 2>/dev/null
    return
  fi
  gcloud config set project "$1"
}

# Switch kubectl context
# Usage: kctx, kctx my-cluster
kctx() {
  if [[ -z "$1" ]]; then
    echo "Contexts:"
    kubectl config get-contexts 2>/dev/null
    return
  fi
  kubectl config use-context "$1"
}

# Switch kubectl namespace
# Usage: kns, kns my-namespace
kns() {
  if [[ -z "$1" ]]; then
    kubectl config view --minify --output 'jsonpath={..namespace}' 2>/dev/null
    echo ""
    return
  fi
  kubectl config set-context --current --namespace="$1"
  echo "Namespace: $1"
}
