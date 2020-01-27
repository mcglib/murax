class UpdateFileSetWithNewFile
      def self.call(filepath, fileset, depositor)
        updated = true
        if !filepath.nil?
          begin
            file_actor = ::Hyrax::Actors::FileSetActor.new(fileset, depositor)
            file_actor.update_content(Hyrax::UploadedFile.create(file: File.open(filepath), user: depositor))
          rescue Ldp::Gone => e
            updated = false
            puts "The file #{fileset} could not be attached to the fileset #{fileset.id}. Server error. See #{e}"
          rescue  StandardError => e
            updated = false
            puts "The file #{fileset} could not be attached to the fileset #{fileset.id}. See #{e}"
          end
        end

        updated
      end

end

