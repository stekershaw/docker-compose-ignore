FROM ubuntu
MAINTAINER Nobody

COPY files tmp

CMD ["ls", "-l", "tmp/test_dir"]
