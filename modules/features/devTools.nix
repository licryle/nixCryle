{ inputs, ... }: {
  flake.nixosModules.devTools = { pkgs, ... }: {
    programs.git = {
      enable = true;
      config = {
        pull.rebase = true;
        init.defaultBranch = "main";
      };
    };

    programs.vscode.enable = true;

    environment.systemPackages = with pkgs; [
      vim
      git-filter-repo
      gh
      lazygit
      pv

      android-studio

      (vscode-with-extensions.override {
        vscodeExtensions = with vscode-extensions; [
          bbenoist.nix
        ];
      })

      opencode
      opencode-desktop
      dos2unix

      (writeScriptBin "git-investigate" ''
        #!${fish}/bin/fish

        for dir in */
          git -C "$dir" rev-parse --git-dir >/dev/null 2>&1; or continue

          echo
          echo "=== $dir ==="

          set -l tracked (git -C "$dir" \
            -c core.fileMode=false \
            diff --name-only --ignore-cr-at-eol HEAD -- 2>/dev/null)

          set -l untracked (git -C "$dir" \
            ls-files --others --exclude-standard)

          if test (count $tracked) -eq 0; and test (count $untracked) -eq 0
            echo "CLEAN"
          else
            echo "DIRTY"

            for file in $tracked
              echo "  MODIFIED  $file"
            end

            for file in $untracked
              echo "  UNTRACKED $file"
            end
          end

          set -l upstream (git -C "$dir" \
            rev-parse --abbrev-ref '@{upstream}' 2>/dev/null)

          if test -z "$upstream"
            echo "NO UPSTREAM configured"
            continue
          end

          set -l count (git -C "$dir" \
            rev-list --count "$upstream..HEAD" 2>/dev/null)

          if test -n "$count"; and test "$count" -gt 0
            echo "UNPUSHED ($count commits)"
            git -C "$dir" log --oneline "$upstream..HEAD"
          end
        end
      '')
    ];

    environment.variables.EDITOR = "code";

    programs.direnv.enable = true;
  };
}