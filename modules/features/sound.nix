{
  flake.modules.nixos.sound = { pkgs, ... }: {
    security.rtkit.enable = true;
    services.pulseaudio.enable = false;
    services.pipewire = {
      enable = true;
      alsa.enable = true;
      alsa.support32Bit = true;
      pulse.enable = true;
      jack.enable = true;
      wireplumber.enable = true;

      # Native PipeWire nodes: no pactl startup commands or device IDs needed.
      extraConfig.pipewire."90-dnd-recording"."context.modules" =
        let
          stereo = [
            "FL"
            "FR"
          ];
          feed = name: capture: {
            name = "libpipewire-module-loopback";
            args = {
              "audio.position" = stereo;
              "capture.props" = {
                "node.name" = "dnd.${name}.capture";
                "node.description" = "D&D ${name}";
                # An unspecified target follows the default mic/speaker.
                "node.passive" = true;
                "node.dont-restore" = true;
              }
              // capture;
              "playback.props" = {
                "node.name" = "dnd.${name}.playback";
                "target.object" = "dnd_recording_sink";
                "node.dont-fallback" = true;
                "node.linger" = true;
                "node.passive" = true;
              };
            };
          };
        in
        [
          {
            name = "libpipewire-module-loopback";
            args = {
              "audio.position" = stereo;
              "capture.props" = {
                "node.name" = "dnd_recording_sink";
                "node.description" = "D&D Recording Mix";
                "media.class" = "Audio/Sink";
                "node.virtual" = true;
                "priority.session" = 0;
              };
              "playback.props" = {
                "node.name" = "dnd_recording_source";
                "node.description" = "D&D Recording";
                "media.class" = "Audio/Source";
                "node.virtual" = true;
                "priority.session" = 0;
              };
            };
          }
          (feed "microphone" { })
          (feed "speakers" { "stream.capture.sink" = true; })
        ];
    };
    programs.dconf.enable = true;
    environment.systemPackages = [ pkgs.pavucontrol ];
  };

  flake.modules.homeManager.sound = {
    services.easyeffects = {
      enable = true;
      preset = {
        input = "microphone-noise-reduction";
        output = "fw13-easy-effects";
      };
      settings = {
        EffectsPipelines = {
          # Keep recording-device choices intact, including the raw D&D mix.
          # Select Easy Effects Source in an app to use the denoised microphone.
          processAllInputs = false;
          processAllOutputs = true;
          excludeMonitorStreams = true;
        };
        StreamInputs = {
          useDefaultInputDevice = true;
          listenToMic = false;
        };
        StreamOutputs = {
          useDefaultOutputDevice = true;
          linkToVirtualSource = false;
        };
      };
      extraPresets = {
        fw13-easy-effects = builtins.fromJSON (
          builtins.readFile ../../assets/easyeffects/fw13-easy-effects.json
        );
        microphone-noise-reduction.input = {
          blocklist = [ ];
          plugins_order = [ "rnnoise#0" ];
          "rnnoise#0" = {
            bypass = false;
            "input-gain" = 0.0;
            "output-gain" = 0.0;
            "model-name" = "";
            "use-standard-model" = true;
            "enable-vad" = false;
            "vad-thres" = 50.0;
            release = 20.0;
            wet = 0.0;
          };
        };
      };
    };
    xdg.dataFile."easyeffects/irs/IR_22ms_27dB_5t_15s_0c.irs".source =
      ../../assets/easyeffects/IR_22ms_27dB_5t_15s_0c.irs;
  };
}
