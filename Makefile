TOP_DIR = ../..
include $(TOP_DIR)/tools/Makefile.common

DEPLOY_RUNTIME ?= /kb/runtime
TARGET ?= /kb/deployment

SERVER_SPEC = JiraSubmission.spec
SERVICE_MODULE = lib/Bio/BVBRC/JiraSubmission/Service.pm
SERVICE = JiraSubmission
SERVICE_PORT = 7200
SERVICE_URL = https://p3.theseed.org/services/$(SERVICE)
SERVICE_NAME = JiraSubmission
SERVICE_PSGI_FILE = $(SERVICE_NAME).psgi

APP_SERVICE = app_service

SRC_PERL = $(wildcard scripts/*.pl)
BIN_PERL = $(addprefix $(BIN_DIR)/,$(basename $(notdir $(SRC_PERL))))
DEPLOY_PERL = $(addprefix $(TARGET)/bin/,$(basename $(notdir $(SRC_PERL))))

SRC_SERVICE_PERL = $(wildcard service-scripts/*.pl)
BIN_SERVICE_PERL = $(addprefix $(BIN_DIR)/,$(basename $(notdir $(SRC_SERVICE_PERL))))
DEPLOY_SERVICE_PERL = $(addprefix $(SERVICE_DIR)/bin/,$(basename $(notdir $(SRC_SERVICE_PERL))))

CLIENT_TESTS = $(wildcard t/client-tests/*.t)
SERVER_TESTS = $(wildcard t/server-tests/*.t)
PROD_TESTS = $(wildcard t/prod-tests/*.t)

STARMAN_WORKERS = 8
STARMAN_MAX_REQUESTS = 100

JIRA_ENDPOINT = https://bv-brc.atlassian.net/rest
JIRA_SERVICEDESK = 5
JIRA_TASK_FAIL_REQUEST = 68
JIRA_BUG_REQUEST = 63

TPAGE_ARGS = --define kb_top=$(TARGET) --define kb_runtime=$(DEPLOY_RUNTIME) --define kb_service_name=$(SERVICE) \
	--define kb_service_port=$(SERVICE_PORT) --define kb_service_dir=$(SERVICE_DIR) \
	--define kb_sphinx_port=$(SPHINX_PORT) --define kb_sphinx_host=$(SPHINX_HOST) \
	--define kb_starman_workers=$(STARMAN_WORKERS) \
	--define kb_starman_max_requests=$(STARMAN_MAX_REQUESTS) \
	--define jira_endpoint=$(JIRA_ENDPOINT) \
	--define jira_user=$(JIRA_USER) \
	--define jira_servicedesk=$(JIRA_SERVICEDESK) \
	--define jira_task_fail_request=$(JIRA_TASK_FAIL_REQUEST) \
	--define jira_bug_request=$(JIRA_BUG_REQUEST) \
	--define jira_api_token=$(JIRA_API_TOKEN) 

all: build-libs bin  compile-typespec service

bin: $(BIN_PERL) $(BIN_SERVICE_PERL)

service: $(SERVICE_MODULE)

compile-typespec: Makefile
	mkdir -p lib/biop3/$(SERVICE_NAME_PY)
	touch lib/biop3/__init__.py #do not include code in biop3/__init__.py
	touch lib/biop3/$(SERVICE_NAME_PY)/__init__.py 
	mkdir -p lib/javascript/$(SERVICE_NAME)
	compile_typespec \
		--patric \
		--psgi $(SERVICE_PSGI_FILE) \
		--impl Bio::BVBRC::$(SERVICE_NAME)::$(SERVICE_NAME)Impl \
		--service Bio::BVBRC::$(SERVICE_NAME)::Service \
		--client Bio::BVBRC::$(SERVICE_NAME)::$(SERVICE_NAME)Client \
		--py biop3/$(SERVICE_NAME_PY)/$(SERVICE_NAME)Client \
		--js javascript/$(SERVICE_NAME)/$(SERVICE_NAME)Client \
		--url $(SERVICE_URL) \
		$(SERVER_SPEC) lib
	-rm -f lib/$(SERVER_MODULE)Server.py
	-rm -f lib/$(SERVER_MODULE)Impl.py

deploy: deploy-all
deploy-all: deploy-client 
deploy-client: build-libs deploy-libs deploy-scripts deploy-docs

build-libs:
	$(TPAGE) $(TPAGE_BUILD_ARGS) $(TPAGE_ARGS) Config.pm.tt > lib/Bio/BVBRC/JiraSubmission/Config.pm

deploy-service: deploy-libs deploy-scripts deploy-service-scripts

deploy-specs:
	mkdir -p $(TARGET)/services/$(APP_SERVICE)
	rsync -arv app_specs $(TARGET)/services/$(APP_SERVICE)/.

deploy-service-scripts:
	export KB_TOP=$(TARGET); \
	export KB_RUNTIME=$(DEPLOY_RUNTIME); \
	export KB_PERL_PATH=$(TARGET)/lib ; \
	for src in $(SRC_SERVICE_PERL) ; do \
	        basefile=`basename $$src`; \
	        base=`basename $$src .pl`; \
	        echo install $$src $$base ; \
	        cp $$src $(TARGET)/plbin ; \
	        $(WRAP_PERL_SCRIPT) "$(TARGET)/plbin/$$basefile" $(TARGET)/bin/$$base ; \
	done


deploy-dir:
	if [ ! -d $(SERVICE_DIR) ] ; then mkdir $(SERVICE_DIR) ; fi
	if [ ! -d $(SERVICE_DIR)/bin ] ; then mkdir $(SERVICE_DIR)/bin ; fi

deploy-docs: 


clean:


$(BIN_DIR)/%: service-scripts/%.pl $(TOP_DIR)/user-env.sh
	$(WRAP_PERL_SCRIPT) '$$KB_TOP/modules/$(CURRENT_DIR)/$<' $@

$(BIN_DIR)/%: service-scripts/%.py $(TOP_DIR)/user-env.sh
	$(WRAP_PYTHON_SCRIPT) '$$KB_TOP/modules/$(CURRENT_DIR)/$<' $@

include $(TOP_DIR)/tools/Makefile.common.rules
