SpecrightDev::Application.routes.draw do
  
  resources :sponsors

  resources :suppliers

  root :to => "homes#index"  
  match 'prints/:id/print_project' => 'prints#print_project', :defaults => { :format => 'pdf' }
 
  get "home" => "homes#index", :as => "home"
  #get "mob_home" => "sessions#new", :as => "mob_home"    
  get "log_out" => "sessions#destroy", :as => "log_out"      
  get "sign_up" => "companies#new", :as => "sign_up"  
  get "prices" => "prices#index", :as => "prices"
  get "terms" => "terms#index", :as => "terms"
  get "about_us" => "abouts#index", :as => "about_us"
  get "faqs" => "faqs#index", :as => "faqs"


  resources :helps do
    get :tutorial, :on => :member
  end
  
  resources :publics
  resources :clauserefs
  resources :features
  resources :guidenotes
  resources :sponsors

  resources :guidedownloads
  resources :sessions
  resources :posts do
    resources :comments
  end

  resources :password_resets do
    get :locked, :on => :member
    get :deactivated, :on => :member
  end

  resources :clausetitles do
    get :autocomplete_clausetitle_text, :on => :collection
  end

  resources :companies do
    resources :users
  end
      
  resources :users do
    get :new_users, :on => :member
    get :edit_user_details, :on => :member
    get :update_licence_status, :on => :member
    get :unlock_user, :on => :member
    get :unlocked, :on => :member
    member do
      put :update_licence_status
      put :update_user_details
    end
  end
  
  resources :clauses do
    post :clause_ref_select, :on => :member
    get :subclause_select, :on => :member
    get :update_clause_select, :on => :member
  end
    
  resources :projects do  
    get :manage_subsections, :on => :member
    post :edit_subsections, :on => :member
    get :empty_project, :on => :member
    get :project_sections, :on => :member
    get :project_subsections, :on => :member    
    member do   
    put :update_project, :as => 'change'    
    end  
  end
  
  resources :speclines do
    get :manage_clauses, :on => :member
    get :manage_clauses_2, :on => :member
    delete :delete_clause, :on => :member
    post :add_clause, :on => :member
    get :new_specline, :on => :member
    delete :delete_specline, :on => :member
    post :edit_clauses, :on => :member
    get :guidance, :on => :member
       
    get :mob_specline_templates, :on => :member
    get :mob_edit_specline, :on => :member
    get :mob_change_linetype, :on => :member
    get :mob_update, :on => :member
    get :mob_show_clauses, :on => :member
    get :mob_add_clause, :on => :member
    get :mob_show_clauses_del, :on => :member
    delete :mob_delete_clause, :on => :member
    delete :mob_delete, :on => :member
    get :mob_new_specline, :on => :member
      
    member do
    put :mob_line_update
    put :move_specline
    put :update_specline_3
    put :update_specline_4
    put :update_specline_5
    put :update_specline_6      
    end    
  end
  
  resources :revisions do
    get :clause_change_info, :on => :member
    get :line_change_info, :on => :member
  member do
  put :print_setting
  end
  end
  
  resources :prints do
    get :print_project, :on => :member
  end 
  
  resources :changes do
    get :reinstate, :on => :member
    get :reinstate_clause, :on => :member
  end

  resources :guidepdfs do
    get :download, :on => :member
  end
  
  resources :products do
    get :csv_product_import, :on => :member
  end
  
end