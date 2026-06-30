# vcpkg Flight Rules

Instructions & Guidelines for:
- Building carbon engine components using vcpkg
- Updating this vcpkg Registry

## vcpkg Primer

If you are new to vcpkg, please read this primer
- [vcpkg Primer](pages/vcpkg-primer.md)	

## Building Carbon Components

All of our carbon components require cmake.
On Windows we use MSVC v141, however we are in the process of upgrading to v145.
On macOS we use AppleClang.

### Instructions for building

For detailed information on how our build system works, please see the section on building
- [How we build Carbon Components](pages/building.md)

Clone the repository, and it's submodules
```
> git clone git@github.com:carbonengine/scheduler.git
> cd scheduler
> git submodule update --init
```

Choose a cmake preset available on your system and configure.
```
> cmake --list-presets
Available configure presets:
  "x64-windows-internal"
  "x64-windows-release"
  "x64-windows-debug"
  "x64-windows-trinitydev"

> cmake --preset x64-windows-release
```

Build the component
```
cmake --build .cmake-build-x64-windows-release
```

## Updating Carbon Components ports

You've make a change to a component, we'll use scheduler as an example. I've created a PR that got accepted into the main branch, and tagged the new version v5.0.0.
Now I want to make that version available to other components through vcpkg.

- First, if I haven't done already, I fork the [carbonengine/vcpkg-registry](https:github.com/carbonengine/vcpkg-registry) repository.
- I then clone that fork of the registry, and make a new branch
```
> git clone git@github.com:<MY GITHUB ACCOUNT>/vcpkg-registry
> cd vcpkg-registry
> git checkout -b ugrade_scheduler
```
- Then I open `ports/carbon-scheduler/portfile.cmake` and change the commit ID:
```
vcpkg_from_git(
  OUT_SOURCE_PATH SOURCE_PATH
  URL git@github.com:carbonengine/scheduler.git
  REF <NEW COMMIT ID> <-- Change this to the new commit ID
  HEAD_REF main
)
...
```
- Then I open `ports/carbon-scheduler/vcpkg.json` and change the version number:
```
{
  "name": "carbon-scheduler",
  "version": "5.0.0", <-- change this to the new version
  "description": "Provides channels and a scheduler for Greenlet coroutines.",
  "homepage": "https://github.com/carbonengine/scheduler",
  ...
```
	- In this step, I also make sure to upgrade any dependency versions that got upgraded in the main scheduler repo's `vcpkg.json` file. When scheduler is built as a vcpkg dependency, the `vcpkg.json` file from the registry will be used to determine dependencies & versions, not the one from the scheduler repo.

- Then I stage and commit my changes
```
> git add -u
> git commit -m "Upgrade carbon-scheler to 5.0.0"
```
- Then I run the update tool python script
`python tools/update-ports.py --all`
- If everything is successful, I should see an automatically generated commit at the head of my branch:
```
Update version registry
This is an automatically generated version update for the following packages:
Update carbon-scheduler
```
- I then push this branch up to my fork and create a pull request to the main branch of [carbonengine/vcpkg-registry](https:github.com/carbonengine/vcpkg-registry) and ask for a review.

- When the pull request is merged, the registry will contain the new version of scheduler

## Creating new Carbon Component vcpkg ports

## Making local changes to dependencies

## Things to consider when adding dependencies from vcpkg