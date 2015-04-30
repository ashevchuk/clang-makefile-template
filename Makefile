# Copyright (C) Lambda Cloud Software 2015

CC = clang
CFLAGS = -O -Wall -g
LDFLAGS = -Dall
CPP = clang
LINK = $(CC)

MAIN_PROG = main

OBJ_DIR = obj
SRC_DIR = src

CONFIG_H = config.h

ALL_INC = -I /usr/local/include \
	-I /usr/include \
	-include $(OBJ_DIR)/include/$(CONFIG_H)

OBJ = $(OBJ_DIR)/main.o \
	$(OBJ_DIR)/test.o

REPO_VER = $(shell git log | head -n1 | grep commit | perl -pe 's/commit\s//')
OS_VER = $(shell uname -a)
SYS_DATE = $(shell date -R -u)
CC_VERSION = $(shell $(CC) --version | head -n 1)

default: all

all: prepare build strip
	echo "Build done"

prepare:
	mkdir -p $(OBJ_DIR)
	mkdir -p $(OBJ_DIR)/include

strip:
	strip $(OBJ_DIR)/$(MAIN_PROG)

link: $(OBJ)
	$(LINK) -o $(OBJ_DIR)/$(MAIN_PROG) $(OBJ) $(LDFLAGS) -L/usr/local/lib -lpcre

build: prepare configure link
#	$(LINK) -o $(OBJ_DIR)/$(MAIN_PROG) $(OBJ) -L$(OBJ_DIR) -L/usr/local/lib -lpcre

configure: $(OBJ_DIR)/include/$(CONFIG_H)
	

$(OBJ_DIR)/include/$(CONFIG_H):
	echo '#ifndef _CONFIG_H_INCLUDED_' > $(OBJ_DIR)/include/$(CONFIG_H)
	echo '#define _CONFIG_H_INCLUDED_' >> $(OBJ_DIR)/include/$(CONFIG_H)
	echo '#define _BUILD_OS_VERSION_ "$(OS_VER)"' >> $(OBJ_DIR)/include/$(CONFIG_H)
	echo '#define _BUILD_CC_VERSION_ "$(CC_VERSION)"' >> $(OBJ_DIR)/include/$(CONFIG_H)
	echo '#define _BUILD_CC_CFLAGS_ "$(CFLAGS)"' >> $(OBJ_DIR)/include/$(CONFIG_H)
	echo '#define _BUILD_CC_LDFLAGS_ "$(LDFLAGS)"' >> $(OBJ_DIR)/include/$(CONFIG_H)
	echo '#define _BUILD_REPO_VERSION_ "$(REPO_VER)"' >> $(OBJ_DIR)/include/$(CONFIG_H)
	echo '#define _BUILD_SYS_DATE_ "$(SYS_DATE)"' >> $(OBJ_DIR)/include/$(CONFIG_H)
	echo '#endif' >> $(OBJ_DIR)/include/$(CONFIG_H)

$(OBJ_DIR)/test.o: $(SRC_DIR)/test.cpp
	$(CPP) -c $(CFLAGS) $(ALL_INC) \
		-o $(OBJ_DIR)/test.o \
		$(SRC_DIR)/test.cpp

$(OBJ_DIR)/main.o: $(SRC_DIR)/main.cpp
	$(CPP) -c $(CFLAGS) $(ALL_INC) \
		-o $(OBJ_DIR)/main.o \
		$(SRC_DIR)/main.cpp

clean:
	rm -rf $(OBJ_DIR)

install:
	$(MAKE) -f objs/Makefile install
