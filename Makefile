MAIN_PROG := main

COPYRIGHT = Copyright (C) Lambda Cloud Software 2015


CC = clang
CPP = clang

LINK = $(CC)

LD_LIBS += -lz

SYS_INC = -I /usr/local/include \
	-I /usr/include \

CFLAGS += -O -Wall -g
CPPFLAGS += -O -Wall -g

LDFLAGS += -Dall
LDDFLAGS += -Dall

OBJ_DIR := obj
SRC_DIR := src

CONFIG_H := config.h

SRC := $(shell find $(SRC_DIR) -type f -name "*.cpp")
HEADERS := $(shell find $(SRC_DIR) -type f -name "*.h")
OBJ := $(patsubst $(SRC_DIR)/%,$(OBJ_DIR)/%,$(patsubst %.cpp,%.o,$(SRC)))
DEFS := $(patsubst $(SRC_DIR)/%,$(OBJ_DIR)/%,$(patsubst %.cpp,%.cpp.d,$(SRC)))

SRC_DIRS = $(sort $(dir $(SRC)))
OBJ_DIRS = $(sort $(dir $(OBJ)))

SYS_DATE := $(shell date -R -u)
OS_VERSION := $(shell uname -a)
CC_VERSION := $(shell $(CC) --version | head -n 1)
CPP_VERSION := $(shell $(CPP) --version | head -n 1)
REPO_VERSION := $(lastword $(shell git log | grep commit | head -n1))


LOCAL_INC := $(sort $(dir $(addprefix -I,$(HEADERS))))
CONFIG_INC += -include $(OBJ_DIR)/include/$(CONFIG_H)

ALL_INC += $(LOCAL_INC)
ALL_INC += $(SYS_INC)
ALL_INC += $(CONFIG_INC)

CFLAGS += $(ALL_INC)
CPPFLAGS += $(ALL_INC)

LDFLAGS += $(LD_LIBS)
LDDFLAGS += $(LD_LIBS)


default: all

all: clean build strip
	@echo Make done

prepare:
	@echo Prepare environment
	@echo Object dirs: $(OBJ_DIRS)
	@echo Object files: $(OBJ)
	@echo Source files: $(SRC)
	@echo Source headers: $(HEADERS)
	@echo Source defs: $(DEFS)
	mkdir -p $(OBJ_DIR)
	mkdir -p $(OBJ_DIRS)
	mkdir -p $(OBJ_DIR)/include

strip:
	strip $(OBJ_DIR)/$(MAIN_PROG)

build: prepare configure define_code link
	@echo Build done

configure: $(OBJ_DIR)/include/$(CONFIG_H)
	@echo Configure done

define_code: $(DEFS)
	@echo Code define done

$(OBJ_DIR)/include/$(CONFIG_H):
	@echo Generating $(CONFIG_H)
	@echo '#ifndef _BUILD_CONFIG_H_INCLUDED_' > $(OBJ_DIR)/include/$(CONFIG_H)
	@echo '	#define _BUILD_CONFIG_H_INCLUDED_' >> $(OBJ_DIR)/include/$(CONFIG_H)
	@echo '	#define _BUILD_OS_VERSION_ "$(OS_VERSION)"' >> $(OBJ_DIR)/include/$(CONFIG_H)
	@echo '	#define _BUILD_CC_VERSION_ "$(CC_VERSION)"' >> $(OBJ_DIR)/include/$(CONFIG_H)
	@echo '	#define _BUILD_CPP_VERSION_ "$(CPP_VERSION)"' >> $(OBJ_DIR)/include/$(CONFIG_H)
	@echo '	#define _BUILD_CC_CPPFLAGS_ "$(CPPFLAGS)"' >> $(OBJ_DIR)/include/$(CONFIG_H)
	@echo '	#define _BUILD_CC_LDDFLAGS_ "$(LDDFLAGS)"' >> $(OBJ_DIR)/include/$(CONFIG_H)
	@echo '	#define _BUILD_CC_CFLAGS_ "$(CFLAGS)"' >> $(OBJ_DIR)/include/$(CONFIG_H)
	@echo '	#define _BUILD_CC_LDFLAGS_ "$(LDFLAGS)"' >> $(OBJ_DIR)/include/$(CONFIG_H)
	@echo '	#define _BUILD_REPO_VERSION_ "$(REPO_VERSION)"' >> $(OBJ_DIR)/include/$(CONFIG_H)
	@echo '	#define _BUILD_SYS_DATE_ "$(SYS_DATE)"' >> $(OBJ_DIR)/include/$(CONFIG_H)
	@echo '	#define _BUILD_COPYRIGHT_ "$(COPYRIGHT)"' >> $(OBJ_DIR)/include/$(CONFIG_H)
	@echo '#endif' >> $(OBJ_DIR)/include/$(CONFIG_H)

$(OBJ_DIR)/%.cpp.d: $(SRC_DIR)/%.cpp
	@echo Building def $@ from $^
	$(CPP) $(CPPFLAGS) -M $^ -o $@

$(OBJ_DIR)/%.o: $(SRC_DIR)/%.cpp
	@echo Building $@ from $^
	$(CPP) -c $(CPPFLAGS) $^ -o $@

link: $(OBJ)
	@echo Linking $(MAIN_PROG)
	$(LINK) $(LDDFLAGS) $(OBJ) -o $(OBJ_DIR)/$(MAIN_PROG)

install:
	$(MAKE) -f $(OBJ_DIR)/Makefile install

.PHONY : clean
clean:
	-rm -rf $(OBJ_DIR)
