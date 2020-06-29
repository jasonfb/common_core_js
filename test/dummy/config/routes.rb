Rails.application.routes.draw do
  mount CommonCoreJs::Engine => "/common_core_js"
end
