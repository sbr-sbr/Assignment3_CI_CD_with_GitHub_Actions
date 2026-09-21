# Assignment 3: CI/CD with GitHub Actions

This project demonstrates a local CI pipeline for a Bash command-line application. The pipeline checks the repository, runs automated tests, and builds a Docker image with a smoke test. It does not deploy to a cloud service.

## Project Structure

```text
.
├── app/app.sh                 # Bash CLI application
├── scripts/lint.sh            # Required-file checks
├── scripts/build.sh           # Docker build and smoke test
├── tests/test.sh              # CLI behavior tests
├── .github/workflows/ci.yml   # GitHub Actions workflow
├── Dockerfile                 # Container image definition
└── compose.yaml               # Compose configuration placeholder
```

## Application

The application is located at `app/app.sh` and is exposed as `/usr/local/bin/app` in the container.

Available commands:

| Command | Description |
| --- | --- |
| `help` | Display usage information |
| `system-info` | Display hostname, user, operating system, kernel, memory, uptime, and CPU information |
| `check-host <host>` | Resolve a host and check network connectivity |
| `check-port <host> <port>` | Validate a TCP port and check connectivity |

Invalid commands return exit code `2`. Missing hosts and invalid ports also return exit code `2`.

## Run Locally

Build the Docker image with the same tag used by the test suite:

```bash
docker build -t assignment3 .
```

Run individual commands:

```bash
docker run --rm assignment3 help
docker run --rm assignment3 system-info
docker run --rm assignment3 check-host localhost
docker run --rm assignment3 check-port localhost 80
```

Run all automated tests:

```bash
IMAGE_NAME=assignment3 ./tests/test.sh
```

The test suite covers:

- help output
- system information
- invalid commands
- missing hosts
- valid hosts
- missing ports
- non-numeric ports
- port zero
- ports above `65535`

## CI Pipeline

The workflow in `.github/workflows/ci.yml` runs on pushes and pull requests. It has three stages:

1. **Validate**: checks required files and Bash syntax.
2. **Test**: builds the `assignment3` image and runs the ten CLI tests.
3. **Docker**: builds the Docker image and runs the build smoke test.

Each GitHub Actions job runs on a fresh runner, so the test job builds its own local image before running `tests/test.sh`.

The jobs run in this order:

```text
validate
	 |
	test
	 |
 docker
```

The order is enforced with `needs` in the workflow. The test job runs only after validation succeeds, and the Docker build runs only after the tests succeed.

## CI Failure Demonstration

To demonstrate CI catching a problem safely, use a temporary branch:

```bash
git checkout -b demonstrate-ci-failure
```

Introduce a temporary Bash syntax error in one of the scripts, commit it, and push the branch:

```bash
git add app/app.sh
git commit -m "Demonstrate CI failure"
git push -u origin demonstrate-ci-failure
```

GitHub Actions should fail during the `validate` job, preventing the `test` and `docker` jobs from running. Record the failed workflow run, then fix the syntax error and push the correction:

```bash
git add app/app.sh
git commit -m "Fix CI demonstration error"
git push
```

The final workflow run should pass all three stages. Document the failed run and the successful correction in the submission or pull request description. Do not leave the intentional error on the main branch.

## Useful Checks

Check Bash syntax without running Docker:

```bash
bash -n app/app.sh scripts/build.sh scripts/lint.sh
sh -n tests/test.sh
```

Run the local repository grader:

```bash
bash grade.sh
```

## Requirements

- Bash
- Docker with the Docker daemon running
- GitHub Actions for CI execution
