

class SiteDemoTemplate < DomainModel
  
  validates_presence_of :name, :directory
  validates_numericality_of :weight
  
  has_domain_file :image_id

  def validate
    if !File.directory?(self.full_directory)
      self.errors.add(:directory,'is not a valid directory')
    end
  end

  def full_directory
    "#{RAILS_ROOT}/#{directory}"
  end
end
