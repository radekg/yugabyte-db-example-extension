EXTENSION = example
DATA = $(wildcard sql/*--*.sql)

MODULE_big = example
OBJS = $(patsubst %.c,%.o,$(wildcard src/*.c))

#ifeq ($(CC),gcc)
#    PG_CPPFLAGS = -std=c99 -Wall -Wextra -Werror -Wno-unused-parameter -Wno-maybe-uninitialized -Wno-implicit-fallthrough -Iinclude -I$(libpq_srcdir)
#else
#    PG_CPPFLAGS = -std=c99 -Wall -Wextra -Werror -Wno-unused-parameter -Wno-implicit-fallthrough -Iinclude -I$(libpq_srcdir)
#endif

TESTS = $(wildcard test/sql/*.sql)
REGRESS = $(patsubst test/sql/%.sql,%,$(TESTS))
REGRESS_OPTS = --use-existing --inputdir=test

# Tell pg_config to pass us the PostgreSQL extensions makefile(PGXS)
# and include it into our own Makefile through the standard "include" directive.
PG_CONFIG = pg_config
PGXS := $(shell $(PG_CONFIG) --pgxs)
include $(PGXS)

# Custom targets:
CURRENT_DIR=$(dir $(realpath $(firstword $(MAKEFILE_LIST))))
DOCKER_IMAGE?=local/example-postgres-extensions-builder:11.2

.PHONY: ext-infra
ext-infra:
	cd ${CURRENT_DIR}/.docker/psql-extensions-build-infra \
		&& docker build -t ${DOCKER_IMAGE} .

.PHONY: ext-clean
ext-clean:
	docker run --rm \
  		-v ${CURRENT_DIR}:/extension \
		-e POSTGRES_PASSWORD=ext-builder \
  		-ti ${DOCKER_IMAGE} clean

.PHONY: ext-build
ext-build:
	docker run --rm \
  		-v ${CURRENT_DIR}:/extension \
		-e POSTGRES_PASSWORD=ext-builder \
  		-ti ${DOCKER_IMAGE} build

.PHONY: ext-run-postgres
ext-run-postgres:
	docker run --rm \
  		-v ${CURRENT_DIR}:/extension \
		-e POSTGRES_PASSWORD=ext-builder \
		-p 5432:5432 \
  		-ti ${DOCKER_IMAGE} run

.PHONY: ext-installcheck
ext-installcheck:
	docker run --rm \
  		-v ${CURRENT_DIR}:/extension \
		-e POSTGRES_PASSWORD=ext-builder \
  		-ti ${DOCKER_IMAGE} installcheck
