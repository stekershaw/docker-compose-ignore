# Background

I'm seeing odd behaviour: `docker-compose` using a `.dockerignore` is behaving differently to `docker build`.

This is perhaps the same as https://github.com/docker/compose/issues/1607?

I'm using Windows 10, using *git bash* as my shell, and Docker toolbox giving me:
```
$ docker -v
Docker version 1.9.1, build a34a1d5

$ docker-compose -v
docker-compose version 1.5.2, build e5cf49d
```

I get expected behaviour - parity between build and compose - using Ubuntu 14.04 with `docker` and `docker-compose` versions:
```
$ docker -v
Docker version 1.9.1, build a34a1d5

$ docker-compose -v
docker-compose version 1.5.2, build 7240ff3
```

# Test cases

This repo has 3 branches, differing only in the `.dockerignore` file:
1. **master** branch: the `.dockerignore` file specifies a single file. I get identical output from `docker build && docker run` and `docker-compose up`: I can't see the ignored file but can see the other of the two files in the *files/test_dir* directory.
1. **bad-1** branch: the `.dockerignore` files specifies a directory. With `docker build` we see no files, as expected, but with `docker-compose up` we see all the files.
1. **bad-2** branch: the `.dockerignore` files specifies a directory plus an exclusion. With `docker build` we see the excluded file, as expected, but with `docker-compose up` we see all the files again.

## What I see

On the *master* branch:
```
$ cat .dockerignore
files/test_dir/should_not_be_here_ever

$ docker build --no-cache --rm -t testing-ignore-master . 2>/dev/null | grep Success
Successfully built 12a2b42d5a8b

$ docker run --rm testing-ignore-master
total 0
-rwxr-xr-x 1 root root 0 Jan 29 14:50 should_be_here_maybe

$ docker-compose up 2>/dev/null | grep test_1
Attaching to dockercomposeignore_test_1
test_1 | total 0
test_1 | -rw-rw-rw- 1 root root 0 Jan 29 14:50 should_be_here_maybe
dockercomposeignore_test_1 exited with code 0
```

Cleaning up before the next test:
```
$ docker rmi testing-ignore-master
Untagged: testing-ignore-master:latest
Deleted: 12a2b42d5a8b4a593c4c5af12870339dbc9cc7ecbaa96d5d40af1a1a45c54ce7
Deleted: 55bfa7ab28a1b3b0e6f4bebddf99d12948479a0283e023de8e6f39d2902a5305

$ yes | docker-compose rm
Going to remove dockercomposeignore_test_1
Removing dockercomposeignore_test_1 ... done

$ docker rmi dockercomposeignore_test
Untagged: dockercomposeignore_test:latest
Deleted: 4450150de0f1ae5140c57a050dba4838cd4e122247d1f092255b28a772c6917a
Deleted: edd7950c813ce5d69442c722c7e685f68d18b52ba9913dab3453aaf0d8d70b28
Deleted: ec5e3e8c3b9d8b7c8647eb55b41a592ac247a1e911c76d42d460701c13aeecf7
```

What I see on branch *bad-1*, ignoring the whole of *files/test_dir*:
```
$ cat .dockerignore
files/test_dir

$ docker build --no-cache --rm -t testing-ignore-bad-1 . 2>/dev/null | grep Success
Successfully built 75200f46e039

$ docker run --rm testing-ignore-bad-1
ls: cannot access tmp/test_dir: No such file or directory

$ docker-compose up 2>/dev/null | grep test_1
Attaching to dockercomposeignore_test_1
test_1 | total 0
test_1 | -rw-rw-rw- 1 root root 0 Jan 29 14:50 should_be_here_maybe
test_1 | -rw-rw-rw- 1 root root 0 Jan 29 14:50 should_not_be_here_ever
dockercomposeignore_test_1 exited with code 0
```

Then clean up similary to before.

What I see on branch *bad-2*, ignoring the whole of *files/test_dir* but with an exception:
```
$ cat .dockerignore
files/test_dir
!files/test_dir/should_be_here_maybe

$ docker build --no-cache --rm -t testing-ignore-bad-2 . 2>/dev/null | grep Success
Successfully built a08488f42c1f

$ docker run --rm testing-ignore-bad-2
total 0
-rwxr-xr-x 1 root root 0 Jan 29 14:50 should_be_here_maybe

$ docker-compose up 2>/dev/null | grep test_1
Attaching to dockercomposeignore_test_1
test_1 | total 0
test_1 | -rw-rw-rw- 1 root root 0 Jan 29 14:50 should_be_here_maybe
test_1 | -rw-rw-rw- 1 root root 0 Jan 29 14:50 should_not_be_here_ever
dockercomposeignore_test_1 exited with code 0
```
