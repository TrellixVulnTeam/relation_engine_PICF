#!/bin/sh

set -e

# Create tarball of the test spec directory
(cd /app/relation_engine_server/test/spec_release && \
  tar czvf spec.tar.gz sample_spec_release)

black .
flake8 --max-complexity 20 /app
mypy --ignore-missing-imports /app
bandit -r /app

# start server, using the specs in /spec/repo
sh /app/scripts/start_server.sh &
coverage erase
# spec validation
python -m spec.validate
# run importer/, relation_engine_server/, and spec/ tests, skip test_query.py
coverage run --branch -m pytest --ignore=spec/test/stored_queries/test_query.py
# RE client tests
PYTHONPATH=client_src python -m pytest client_src/test
coverage html --omit=*/test_*
