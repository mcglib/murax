class ImportLog < ApplicationRecord
  belongs_to :batch
  scope :not_imported, -> { where(imported: false) }

  def imported?
    return self.imported
  end
end
