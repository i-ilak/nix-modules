{
  pkgs,
  ...
}:
{
  programs.helix = {
    languages = {
      language = [
        {
          name = "cpp";
          scope = "source.cpp";
          injection-regex = "cpp";
          auto-format = true;
          formatter.command = "${pkgs.llvmPackages_20.clang-tools}/bin/clang-format";
          file-types = [
            "cc"
            "hh"
            "c++"
            "cpp"
            "hpp"
            "h"
            "ipp"
            "tpp"
            "cxx"
            "hxx"
            "ixx"
            "txx"
            "ino"
            "C"
            "H"
            "cu"
            "cuh"
            "cppm"
            "h++"
            "ii"
            "inl"
            { glob = ".hpp.in"; }
            { glob = ".h.in"; }
          ];
          comment-token = "//";
          block-comment-tokens = {
            start = "/*";
            end = "*/";
          };
          language-servers = [ "clangd" ];
          indent = {
            tab-width = 2;
            unit = "  ";
          };
          debugger = {
            name = "lldb-dap";
            transport = "stdio";
            command = "${pkgs.vscode-extensions.vadimcn.vscode-lldb}/share/vscode/extensions/vadimcn.vscode-lldb/lldb/bin/lldb-dap";
            templates = [
              {
                name = "binary";
                request = "launch";
                completion = [
                  {
                    name = "binary";
                    completion = "filename";
                  }
                ];
                args = {
                  console = "internalConsole";
                  program = "{0}";
                };
              }
              {
                name = "attach";
                request = "attach";
                completion = [ "pid" ];
                args = {
                  console = "internalConsole";
                  pid = "{0}";
                };
              }
              {
                name = "gdbserver attach";
                request = "attach";
                completion = [
                  {
                    name = "lldb connect url";
                    default = "connect://localhost:3333";
                  }
                  {
                    name = "file";
                    completion = "filename";
                  }
                  "pid"
                ];
                args = {
                  console = "internalConsole";
                  attachCommands = [
                    "platform select remote-gdb-server"
                    "platform connect {0}"
                    "file {1}"
                    "attach {2}"
                  ];
                };
              }
            ];
          };
        }
      ];
      language-servers = {
        "clangd" = {
          command = "clangd";
          args = [
            "--offset-encoding=utf-16"
            "--background-index"
            "-j"
            "20"
            "--clang-tidy"
          ];
        };
      };
      grammars = [
        {
          name = "cpp";
          source = {
            git = "https://github.com/tree-sitter/tree-sitter-cpp";
            rev = "f41e1a044c8a84ea9fa8577fdd2eab92ec96de02";
          };
        }
      ];
    };
  };
}
