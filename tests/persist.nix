{ lib }:
let
  inherit (lib) evalModules hasInfix;

  persistModule = ../modules/nixos/persist.nix;

  # Minimal stubs for options that persist.nix writes to / relies on.
  # We don't want to pull in the full NixOS module system or the impermanence
  # flake input just to unit-test option shaping and assertions.
  stubsModule =
    { lib, ... }:
    {
      options.environment.persistence = lib.mkOption {
        type = lib.types.attrsOf (
          lib.types.submodule {
            options = {
              directories = lib.mkOption {
                type = lib.types.listOf lib.types.anything;
                default = [ ];
              };
              files = lib.mkOption {
                type = lib.types.listOf lib.types.anything;
                default = [ ];
              };
              hideMounts = lib.mkOption {
                type = lib.types.bool;
                default = false;
              };
            };
          }
        );
        default = { };
      };
      # Mirror nixpkgs/nixos/modules/misc/assertions.nix just enough so that
      # persist.nix's assertions show up in config.assertions without forcing
      # a full NixOS eval.
      options.assertions = lib.mkOption {
        type = lib.types.listOf lib.types.unspecified;
        default = [ ];
        internal = true;
      };
    };

  evalPersist =
    entries:
    evalModules {
      modules = [
        stubsModule
        persistModule
        {
          infra.persist = {
            enable = true;
            inherit entries;
          };
        }
      ];
    };

  dirs = entries: (evalPersist entries).config.environment.persistence."/persist".directories;
  files = entries: (evalPersist entries).config.environment.persistence."/persist".files;
  failingAssertions = entries: lib.filter (a: !a.assertion) (evalPersist entries).config.assertions;

  # For tests that expect the option type system to reject an entry outright,
  # force evaluation of the entries list and observe whether it throws.
  tryEntriesEval =
    entries:
    (builtins.tryEval (lib.deepSeq (evalPersist entries).config.infra.persist.entries true)).success;
in
{
  # ---------------------------------------------------------------------------
  # Happy path: entries shape cleanly into impermanence's directories/files.
  # ---------------------------------------------------------------------------

  testDirAllFieldsNull = {
    expr = dirs [
      {
        directory = "/var/lib/foo";
        reason = "service manages ownership";
      }
    ];
    expected = [ { directory = "/var/lib/foo"; } ];
  };

  testDirModeOnly = {
    expr = dirs [
      {
        directory = "/var/lib/foo";
        mode = "0700";
        reason = "mode only";
      }
    ];
    expected = [
      {
        directory = "/var/lib/foo";
        mode = "0700";
      }
    ];
  };

  testDirUserAndGroupNoMode = {
    expr = dirs [
      {
        directory = "/var/lib/foo";
        user = "foo";
        group = "foo";
        reason = "fixed user";
      }
    ];
    expected = [
      {
        directory = "/var/lib/foo";
        user = "foo";
        group = "foo";
      }
    ];
  };

  testDirAllFieldsSet = {
    expr = dirs [
      {
        directory = "/var/lib/foo";
        user = "redis-authentik";
        group = "redis-authentik";
        mode = "0700";
        reason = "full ownership";
      }
    ];
    expected = [
      {
        directory = "/var/lib/foo";
        user = "redis-authentik";
        group = "redis-authentik";
        mode = "0700";
      }
    ];
  };

  testFileEntryEmitsBarePath = {
    expr = files [
      {
        file = "/var/lib/foo.status";
        reason = "cursor";
      }
    ];
    expected = [ "/var/lib/foo.status" ];
  };

  testMixedEntriesSplitCorrectly = {
    expr = {
      dirs = dirs [
        {
          directory = "/var/lib/a";
          reason = "a";
        }
        {
          file = "/var/lib/b.status";
          reason = "b";
        }
        {
          directory = "/var/lib/c";
          mode = "0700";
          reason = "c";
        }
      ];
      files = files [
        {
          directory = "/var/lib/a";
          reason = "a";
        }
        {
          file = "/var/lib/b.status";
          reason = "b";
        }
        {
          directory = "/var/lib/c";
          mode = "0700";
          reason = "c";
        }
      ];
    };
    expected = {
      dirs = [
        { directory = "/var/lib/a"; }
        {
          directory = "/var/lib/c";
          mode = "0700";
        }
      ];
      files = [ "/var/lib/b.status" ];
    };
  };

  # ---------------------------------------------------------------------------
  # Assertions: module should catch misuse that the option types can't.
  # ---------------------------------------------------------------------------

  testBothDirectoryAndFileFailsAssertion = {
    expr =
      let
        failing = failingAssertions [
          {
            directory = "/var/lib/foo";
            file = "/var/lib/foo.status";
            reason = "bad";
          }
        ];
      in
      builtins.any (a: hasInfix "exactly one of" a.message) failing;
    expected = true;
  };

  testNeitherDirectoryNorFileFailsAssertion = {
    expr =
      let
        failing = failingAssertions [ { reason = "bad"; } ];
      in
      builtins.any (a: hasInfix "exactly one of" a.message) failing;
    expected = true;
  };

  testFileWithModeFailsAssertion = {
    expr =
      let
        failing = failingAssertions [
          {
            file = "/var/lib/foo.status";
            mode = "0600";
            reason = "bad";
          }
        ];
      in
      builtins.any (a: hasInfix "cannot set" a.message) failing;
    expected = true;
  };

  testFileWithUserFailsAssertion = {
    expr =
      let
        failing = failingAssertions [
          {
            file = "/var/lib/foo.status";
            user = "foo";
            reason = "bad";
          }
        ];
      in
      builtins.any (a: hasInfix "cannot set" a.message) failing;
    expected = true;
  };

  testFileWithGroupFailsAssertion = {
    expr =
      let
        failing = failingAssertions [
          {
            file = "/var/lib/foo.status";
            group = "foo";
            reason = "bad";
          }
        ];
      in
      builtins.any (a: hasInfix "cannot set" a.message) failing;
    expected = true;
  };

  testValidDirEntryHasNoFailingAssertions = {
    expr = failingAssertions [
      {
        directory = "/var/lib/foo";
        user = "foo";
        group = "foo";
        mode = "0755";
        reason = "ok";
      }
    ];
    expected = [ ];
  };

  testValidFileEntryHasNoFailingAssertions = {
    expr = failingAssertions [
      {
        file = "/var/lib/foo.status";
        reason = "ok";
      }
    ];
    expected = [ ];
  };

  # ---------------------------------------------------------------------------
  # Type narrowing: bad values should be rejected by strMatching, not silently
  # accepted. tryEntriesEval returns false when option evaluation throws.
  # ---------------------------------------------------------------------------

  testRelativeDirectoryRejected = {
    expr = tryEntriesEval [
      {
        directory = "var/lib/foo";
        reason = "bad";
      }
    ];
    expected = false;
  };

  testBareSlashDirectoryRejected = {
    expr = tryEntriesEval [
      {
        directory = "/";
        reason = "bad";
      }
    ];
    expected = false;
  };

  testRelativeFileRejected = {
    expr = tryEntriesEval [
      {
        file = "var/lib/foo.status";
        reason = "bad";
      }
    ];
    expected = false;
  };

  testEmptyDirectoryRejected = {
    expr = tryEntriesEval [
      {
        directory = "";
        reason = "bad";
      }
    ];
    expected = false;
  };

  testSymbolicModeRejected = {
    expr = tryEntriesEval [
      {
        directory = "/var/lib/foo";
        mode = "u=rwx,g=rx,o=";
        reason = "bad";
      }
    ];
    expected = false;
  };

  testNonOctalModeRejected = {
    expr = tryEntriesEval [
      {
        directory = "/var/lib/foo";
        mode = "0800";
        reason = "bad";
      }
    ];
    expected = false;
  };

  testTooShortModeRejected = {
    expr = tryEntriesEval [
      {
        directory = "/var/lib/foo";
        mode = "70";
        reason = "bad";
      }
    ];
    expected = false;
  };

  testUserStartingWithHyphenRejected = {
    expr = tryEntriesEval [
      {
        directory = "/var/lib/foo";
        user = "-user";
        reason = "bad";
      }
    ];
    expected = false;
  };

  # POSIX allows leading digits in user names, so this must be accepted.
  testUserStartingWithDigitAccepted = {
    expr = tryEntriesEval [
      {
        directory = "/var/lib/foo";
        user = "123user";
        reason = "ok";
      }
    ];
    expected = true;
  };

  testUserWithSpaceRejected = {
    expr = tryEntriesEval [
      {
        directory = "/var/lib/foo";
        user = "foo bar";
        reason = "bad";
      }
    ];
    expected = false;
  };

  testUserWithSpecialCharRejected = {
    expr = tryEntriesEval [
      {
        directory = "/var/lib/foo";
        user = "foo!";
        reason = "bad";
      }
    ];
    expected = false;
  };

  # POSIX portable filename character set includes `.`, so `foo.bar` is valid.
  testGroupWithDotAccepted = {
    expr = tryEntriesEval [
      {
        directory = "/var/lib/foo";
        group = "foo.bar";
        reason = "ok";
      }
    ];
    expected = true;
  };

  # ---------------------------------------------------------------------------
  # Type narrowing: real-world names from the nix-config consumer must pass.
  # These are names that exist on maloja today — guard against regex
  # over-restriction.
  # ---------------------------------------------------------------------------

  testRealWorldUserNamesAccepted = {
    expr = tryEntriesEval (
      map
        (u: {
          directory = "/var/lib/foo";
          user = u;
          group = u;
          reason = "real user";
        })
        [
          "root"
          "redis-authentik"
          "redis-paperless"
          "redis-immich"
          "tandoor_recipes"
          "influxdb2"
          "stream"
          "paperless"
          "immich"
          "caddy"
          "acme"
          "jellyfin"
          "hass"
          "loki"
          "grafana"
          "prometheus"
          "navidrome"
          "postgres"
        ]
    );
    expected = true;
  };

  testRealWorldOctalModesAccepted = {
    expr = tryEntriesEval (
      map
        (m: {
          directory = "/var/lib/foo";
          mode = m;
          reason = "real mode";
        })
        [
          "0700"
          "0710"
          "0750"
          "0755"
          "700"
          "755"
        ]
    );
    expected = true;
  };
}
