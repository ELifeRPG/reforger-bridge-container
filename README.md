# eliferpg/reforger-bridge-container

The released [Reforger Bridge](https://github.com/ELifeRPG/reforger-bridge) binaries on the current ASP.NET Core
runtime, published as **`ghcr.io/eliferpg/reforger-bridge`**.

| Image | Dockerfile | Contents |
| --- | --- | --- |
| `ghcr.io/eliferpg/reforger-bridge` | [`api/Dockerfile`](./api/Dockerfile) | `reforger-bridge-api-<version>.tar.gz` from the bridge release, on `mcr.microsoft.com/dotnet/aspnet` |

Binaries and runtime are versioned separately: the bridge repo cuts releases (its **Release**
workflow), and this repo decides which release runs on which runtime. A runtime or OS patch ships
by rebuilding here, with no new bridge release.

## Tags

| Tag | Meaning |
| --- | --- |
| `latest` | Newest release on the newest runtime: what hosting runs |
| `X.Y.Z` | That bridge release, moved to each new runtime as it lands |
| `sha-<commit>` | Exactly this repo's commit (release + runtime digest) |
| `edge` | Not from here: built from source on every push to the bridge's `main` |

## Updates

[Renovate](https://docs.renovatebot.com) opens a PR when the bridge publishes a release (custom
regex manager in [`renovate.json`](./renovate.json), reading the `# renovate:` comment above
`ENV ELIFERPG_BRIDGE_VERSION`) and when the `aspnet` base image changes (tag and digest, so
Microsoft's in-place rebuilds with OS patches arrive too).

CI ([`build.yml`](./.github/workflows/build.yml)) builds every PR and runs
[`scripts/smoke-test.sh`](./scripts/smoke-test.sh), which boots the image and checks that `/ping`
answers. Merging to `main` pushes `:latest`, `:X.Y.Z` and `:sha-<commit>`.

## Adding a deployable

When the bridge releases another deployable (`reforger-bridge-<name>-X.Y.Z.tar.gz`), add
`<name>/Dockerfile` next to `api/`, a matrix entry in `build.yml` with its image
(`ghcr.io/eliferpg/reforger-bridge-<name>`), and a smoke test for it (`scripts/smoke-test.sh` boots the API).

## Local

```sh
docker build -t eliferpg/reforger-bridge:dev api
scripts/smoke-test.sh eliferpg/reforger-bridge:dev   # needs docker and curl; SMOKE_PORT to move the port
```
