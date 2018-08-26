VER=$(shell egrep version setup.py|egrep -o '[0-9.]+')
TARGET=mytools-$(VER)-*.whl

all:clean
	python setup.py sdist bdist_wheel || true

install:all
	pip install -I --no-deps dist/$(TARGET)

clean:
	python setup.py clean --all
