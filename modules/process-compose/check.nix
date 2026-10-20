{ pkgs, self }:
let
  pcWrapped =
    (self.wrapperModules.process-compose.apply {
      inherit pkgs;
      processConfig = {
        version = "0.5";
        processes = {
          process1 = {
            command = "sleep 3";
            depends_on = {
              process2 = {
                condition = "process_completed_successfully"; # or "process_completed" if you don't care about errors
              };
            };
          };
          process2 = {
            command = "sleep 3";
          };
        };
      };
    }).wrapper;

in
pkgs.runCommand "process-compose-test" { } ''
  export PROC_COMP_CONFIG=$(mktemp -d)
  [[ "$(${pcWrapped}/bin/process-compose version)" == *Process\ Compose* ]]
  touch $out
''
