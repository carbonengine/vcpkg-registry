# Skip proactor event loop tests

These tests seem to run fine locally, but somehow end up hanging on our Team City build agents. The cause seems to be that they expect ERROR_PORT_UNREACHABLE to be received by a UDP socket after using that same socket to send to an address which was not listening.

When this error occurs,the `IocpProactor` class' `recvfrom` method should return an empty result. However, on the build agent, this error doesn't show up, so the tests hang forever waiting to receive.

This seems like an environmental issue with the build agents rather than a problem with the build itself, so the solution for now is to disable the tests.

For details, see the [pull request which added these tests](https://github.com/python/cpython/pull/32011).
