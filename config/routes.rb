SpecrightDev::Application.routes.draw do
  
  get "productimports/new"

  get "productimports/create"

  resources :sponsors

  resources :suppliers

  root :to => "homes#index"  
  match 'prints/:id/print_project' => 'prints#print_project', :defaults => { :format => 'pdf' }
  match 'productimports/:id/product_error_print' => 'productimports#product_error_print', :defaults => { :format => 'pdf' } 

 
  get "home" => "homes#index", :as => "home"
    
  get "log_out" => "sessions#destroy", :as => "log_out"      
  get "sign_up" => "companies#new", :as => "sign_up"  
  get "terms" => "terms#index", :as => "terms"
  get "about_us" => "abouts#index", :as => "about_us"
  get "faqs" => "faqs#index", :as => "faqs"
  get "combined" => "homes#combined_home", :as => "combined"
  get "supplier" => "homes#supplier_home", :as => "supplier"
  get 'guidepdfs', to: redirect('/features/9')
  
  resources :exports do
    get :keynote_export, :on => :member
  end
  
  resources :helps do
    get :tutorial, :on => :member
  end
  
  resources :publics
  resources :clauserefs
  resources :features
  resources :guidenotes
  resources :sponsors
  resources :guidedownloads
  resources :priceplans
  resources :planfeatures

  
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
    get :new_clone_project_list, :on => :member
    get :new_clone_subsection_list, :on => :member
    get :new_clone_clause_list, :on => :member    
  end
    
  resources :projects do  
    get :manage_subsections, :on => :member
    post :add_subsections, :on => :member
    post :delete_subsections, :on => :member
    get :empty_project, :on => :member
    get :project_sections, :on => :member
    get :project_subsections, :on => :member 
    get :project_subsections, :on => :member 
    get :show_tab_content, :on => :member   
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
    post :add_clauses, :on => :member
    post :delete_clauses, :on => :member
    get :guidance, :on => :member
    get :xref_data, :on => :member

             
    member do
    put :move_specline
    put :update_specline_3
    put :update_specline_4
    put :update_specline_5
    put :update_specline_6
    put :update_product_key
    put :update_product_value       
    end    
  end
  
  resources :revisions do
    get :show_prelim_tab_content, :on => :member
    get :show_rev_tab_content, :on => :member
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
    get :product_keys, :on => :member
    get :product_values, :on => :member
  end
  
 
  resources :productexports
  resources :productimports do
    get :csv_product_upload, :on => :member
    get :product_error_print, :on => :member
  end
  resources :productreports
  resources :productimports

  namespace :api, defaults: {format: 'json'} do
    namespace :v1 do
      resources :downloadguides
    end
  end
resources :downloadguides

  resources :sessions do
    collection do
      post :create_session
    end    
  end
  
end