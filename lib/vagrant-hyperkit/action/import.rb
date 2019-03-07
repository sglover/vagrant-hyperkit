require "log4r"
require "json"
require "fileutils"

module VagrantPlugins
  module HYPERKIT
    module Action
      # This terminates the running instance.
      class Import
        def initialize(app, env)
          @app = app
        end

        def call(env)

          #TODO: Progress bar
          env[:ui].info("Importing box...")

          image_dir = File.join(env[:machine].data_dir, "image")
          box_dir = env[:machine].box.directory

          log.debug("Importing box from: #{box_dir}")

          create_image_directory(image_dir)
          copy_kernel_to(box_dir, image_dir)
          copy_initrd_to(box_dir, image_dir)
          copy_block_files_to(box_dir, image_dir)
          env[:ui].info("Done importing box.")

          @app.call(env)
        end

        private

        def copy_kernel_to(from, to)
          copy_file(from, to, "vmlinuz")
        end

        def copy_initrd_to(from, to)
          copy_file(from, to, "initrd.gz")
        end

        def copy_block_files_to(from, to)
          block_glob = Dir.glob(File.join(from, "block*.{img,raw,qcow,qcow2}"))
          log.debug("Copying #{block_glob} to #{to} ")
          FileUtils.cp_r block_glob, to
        end

        def copy_file(from, to, filename)
          from_box_file_path = File.join(from, filename)
          to_image_file_path = File.join(to, filename)

          unless File.exist? to_image_file_path
            log.debug("Copying #{from_box_file_path} to #{to} ")
            FileUtils.cp(from_box_file_path, to)
          end
        end

        def create_image_directory(path)
          FileUtils.mkdir_p(path)
        end

        def log
          @logger ||= Log4r::Logger.new("vagrant_hyperkit::action::import")
        end
      end
    end
  end
end
