#!/usr/bin/env bash
set -u

PASS=0
FAIL=0

pass() {
    echo "PASS:$1"
    PASS=$((PASS + 1))
}

fail() {
    echo "FAIL:$1"
    FAIL=$((FAIL + 1))
}

echo "======================================="
echo "Assignment3-LocalGrader"
echo "GitHubActions/Docker/Bash"
echo "======================================="
echo

for f in \
    README.md \
    app/app.sh \
    scripts/lint.sh \
    scripts/build.sh \
    tests/test.sh \
    Dockerfile \
    compose.yaml \
    .dockerignore \
    .github/workflows/ci.yml; do
    if [[ -f "$f" ]]; then
        pass "Required file exists: $f"
    else
        fail "Missing required file: $f"
    fi
done

for f in app/*.sh scripts/*.sh tests/*.sh; do
    [[ -f "$f" ]] || continue
    if bash -n "$f" >/dev/null 2>&1; then
        pass "Bash syntax: $f"
    else
        fail "Bash syntax error: $f"
    fi
done

for f in app/app.sh scripts/lint.sh scripts/build.sh tests/test.sh; do
    [[ -f "$f" ]] || continue
    if [[ -x "$f" ]]; then
        pass "Executable: $f"
    else
        fail "Not executable: $f"
    fi
done

WORKFLOW=".github/workflows/ci.yml"
if [[ -f "$WORKFLOW" ]]; then
    if grep -Eq 'push:' "$WORKFLOW"; then
        pass "Workflow triggers on push"
    else
        fail "Workflow missing push trigger"
    fi

    if grep -Eq 'pull_request:' "$WORKFLOW"; then
        pass "Workflow triggers on pull_request"
    else
        fail "Workflow missing pull_request trigger"
    fi
else
    fail "Workflow missing: $WORKFLOW"
fi

echo "PASS=$PASS"
echo "FAIL=$FAIL"

if [ "$FAIL" -eq 0 ]; then
    exit 0
fi

exit 1
