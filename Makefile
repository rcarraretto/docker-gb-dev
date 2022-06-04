build:
	docker build -t gb .

run:
	mkdir -p work
	docker run --name='gb' --rm -it -p 8080:8080 -v "${PWD}/work:/home/gbdev" gb
