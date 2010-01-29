
class SiteDemo::AdminController < ModuleController

 component_info 'SiteDemo', :description => 'Site Demo support', 
                              :access => :private
                              
 # Register a handler feature
 register_permission_category :site_demo, "SiteDemo" ,"Permissions related to Site Demo"
  
 register_permissions :site_demo, [ [ :manage, 'Manage Site Demo', 'Manage Site Demo' ],
                                  [ :config, 'Configure Site Demo', 'Configure Site Demo' ]
                                  ]
 cms_admin_paths "options",
    "Site Demo Options" => { :action => 'index' },
    "Options" => { :controller => '/options' },
    "Modules" => { :controller => '/modules' }

 permit 'site_demo_config'

 content_model :site_demos
   

  def self.get_site_demos_info
    [
      {:name => "Site Demos",
      :url => { :controller => '/site_demo/manage' },
      :permission => :site_demo_manage,
      :icon => 'icons/content/forms_icon.png' }
    ]
  end
    
    

 public 
 
 def options
    cms_page_path ['Options','Modules'],"Site Demo Options"
    
    @options = self.class.module_options(params[:options])
    
    if request.post? && @options.valid? && params[:commit]
      Configuration.set_config_model(@options)
      flash[:notice] = "Updated Site Demo module options".t 
      redirect_to :controller => '/modules'
      return
    elsif request.post? 
      redirect_to :controller => '/modules'
    end    
   render :template => '/application/options_form'
  end
  
  def self.module_options(vals=nil)
    Configuration.get_config_model(Options,vals)
  end
  
  class Options < HashModel
    attributes :limit => 20, :domain_name => '', :time_limit => 60, :template_list => '', :mail_template_id => nil

    validates_presence_of :domain_name
    integer_options :limit, :time_limit
    validates_numericality_of :time_limit
    validates_presence_of :mail_template_id
    # Options attributes 

    options_form(
                 fld(:limit,:text_field,:description => 'Total domain limit'),
                 fld(:domain_name,:text_field,:description => 'name to use for new domains, use %%index%% for next domain index'),
                 fld(:time_limit,:text_field,:description => 'Limit in minutes domain should be active'),
                 fld(:mail_template_id,:select,:options => :mail_templates)
                 )
    def mail_templates
      MailTemplate.select_options_with_nil
    end
                  
  end
  
end
