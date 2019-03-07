require 'xhyve'

module VagrantPlugins
  module HYPERKIT
    module Util
      # TODO: send all this upstream
      class XhyveGuest < Xhyve::Guest

        def initialize(**opts)
          log.info("Guest1")
          super.tap do |s|
            log.info("Guest2")
            @pid = opts.fetch(:pid, nil)
            log.info("Guest3")
            @mac = opts[:mac] unless opts[:mac].nil?
            log.info("Guest4")
          end
          log.info("Guest5")
        end

        def start
          return @pid if running?
          super
        end

        def options
          {
            :pid => @pid,
            :kernel => @kernel,
            :initrd => @initrd,
            :cmdline => @cmdline,
            :blockdevs => @blockdevs,
            :memory => @memory,
            :processors => @processors,
            :uuid => @uuid,
            :serial => @serial,
            :acpi => @acpi,
            :networking => @networking,
            :foreground => @foreground,
            :command => @command,
            :mac => @mac,
            :ip => ip,
            :binary => @binary
          }
        end

        def build_command
          cmd = [
            "sudo",
            "#{@binary}",
            "#{'-A' if @acpi}",
            '-U', @uuid,
            '-m', @memory,
            '-c', @processors,
            '-s', '0:0,hostbridge',
            "#{"-s #{PCI_BASE - 2}:0,virtio-net,en0" if @networking }" ,
            "#{build_block_device_parameter}",
            '-s', '31,lpc',
            '-l', "#{@serial},stdio",
            '-f', "kexec,#{@kernel},#{@initrd},'#{@cmdline}'"
          ].join(' ')

          cmd
        end

        def log
          @logger ||= Log4r::Logger.new("vagrant_hyperkit::vagrant_hyperkit")
        end

        def build_block_device_parameter
          block_device_parameter = ""
          @blockdevs.each_with_index.map do |p, i|
            if p.include? "qcow"
              block_device_parameter << "-s #{PCI_BASE + i},virtio-blk,file://#{p},format\=qcow "
            else
              block_device_parameter << "-s #{PCI_BASE + i},virtio-blk,#{p} "
            end
          end
          block_device_parameter
        end
      end
    end
  end
end
