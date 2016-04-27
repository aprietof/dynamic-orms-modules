class Post

  ATTRIBUTES = {
    :id => "INTEGER PRIMARY KEY",
    :title => "TEXT",
    :content => "TEXT",
    :author_name => "TEXT"
  }


  include Persistable::InstanceMethods
  extend Persistable::ClassMethods

end
