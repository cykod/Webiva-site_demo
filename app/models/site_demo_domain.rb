require 'fileutils'

class SiteDemoDomain < DomainModel


  has_many :site_demo_log_entries

  belongs_to :site_demo_template
  validates_uniqueness_of :name
  validates_uniqueness_of :domain_index
  validates_presence_of :site_demo_template

  include WebivaCaptcha::ModelSupport

  attr_accessor :expiration_minutes

  def self.new_domain(template_id,expiration_minutes = nil)
    email_address = 'demo@webiva.org'

    dmn = self.find(:first,:conditions => [ 'active=0'],:lock => true)
    if dmn
      if dmn.update_attributes(:active => true,:login_email => email_address, :site_demo_template_id => template_id,:expires_at => nil )
        dmn.run_worker(:activate_domain, :expiration => expiration_minutes)
      end
      return dmn
    else
      cnt = SiteDemoDomain.count
      if cnt < SiteDemo::AdminController.module_options.limit
        dmn = SiteDemoDomain.create(:active => true,:login_email => email_address, :site_demo_template_id => template_id,:expires_at => nil)
        if !dmn.valid?
          return dmn
        end
        dmn.run_worker(:activate_domain, :expiration => expiration_minutes)
        return dmn
      else
        return nil
      end
    end
    
  end

  def before_validation_on_create
    self.domain_index = (SiteDemoDomain.maximum(:domain_index)||0) + 1
    opts =  SiteDemo::AdminController.module_options
    
    self.name = variable_replace(opts.domain_name, { :index => domain_index })
    self.login_password = self.class.generate_hash[0..10]
  end


  def activate_domain(args)
    # Find the template - run the restore script on it
    if !self.domain_id
      domain = Domain.find(:first,:conditions => { :name => self.name })
      if domain
        self.domain_id = domain.id
      end
    end
    if self.domain_id
      `cd #{RAILS_ROOT}; rake cms:restore DOMAIN_ID=#{self.domain_id} DIR=#{self.site_demo_template.full_directory}`
    else
      `cd #{RAILS_ROOT}; rake cms:restore DOMAIN=#{self.name} CLIENT_ID=1 DIR=#{self.site_demo_template.full_directory}`
      domain = Domain.find(:first,:conditions => { :name => self.name })
      self.domain_id = domain.id if domain
      return false if !domain
    end

    opts =  SiteDemo::AdminController.module_options
    self.login_password = self.class.generate_hash[0..10]
    self.expires_at = Time.now + (args[:expiration] || opts.time_limit).to_i.minutes
    self.activated_at = Time.now
    self.save

    url = "http://#{name}/website"
    link = "<a href='#{url}'>#{url}</a>"

    if self.login_email != 'demo@webiva.org'
      mail_template = MailTemplate.find_by_id(opts.mail_template_id)
      mail_template.deliver_to_address(self.login_email,
                                     { :password => self.login_password,
                                       :email => self.login_email,
                                       :link => link,
                                       :url => url,
                                       :expires_at => self.expires_at.to_s(:short)
                                     })
    end
    SiteDemoLogEntry.create(self.attributes.symbolize_keys.slice(:login_email,:login_password,:name,:site_demo_template_id))
    

    attr = self.attributes.clone
    DomainModel.activate_domain(self.domain_id)

    usr = EndUser.push_target(attr['login_email'],:first_name => attr['login_email'],:password => attr['login_password'],:password_confirmation => attr['login_password'], :user_class_id => UserClass.domain_user_class_id, :registered => 1 )
  end

  def self.harvest_domains

    current_domain_id = Configuration.active_domain_id

    domains = SiteDemoDomain.find(:all,:conditions => ['active=1 AND expires_at IS NOT NULL AND expires_at < ? ',Time.now]).map(&:attributes)

    domains.each do |domain|
      puts "Deactivating domain:" + domain['name']
      if domain['domain_id']
        DomainModel.activate_domain(domain['domain_id'].to_i)
        EndUser.destroy_all
        domain_entry = Domain.find(domain['domain_id'])

        FileUtils.rm_rf("#{RAILS_ROOT}/public/system/storage/#{domain_entry.file_store}")
        FileUtils.rm_rf("#{RAILS_ROOT}/public/system/private/#{domain_entry.file_store}")
        domain_entry.update_attributes(:iteration => domain_entry.iteration + 1,:active => false,:inactive_message => 'This Demo has expired')

        
      
        DomainModel.activate_domain(current_domain_id.to_i)
      end
      dmn = SiteDemoDomain.find_by_id(domain['id'])
      dmn.update_attributes(:active => false)
    end
    
  end

  def self.domains_available?
    cnt = SiteDemoDomain.count(:all,:conditions => '`active`=1')
    (cnt < SiteDemo::AdminController.module_options.limit)
  end


end
