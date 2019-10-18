class ImportLog < ApplicationRecord
  belongs_to :batch
  scope :not_imported, -> { where(imported: false) }
  scope :imported, -> { where(imported: true) }

  def imported?
    return self.imported
  end
end
