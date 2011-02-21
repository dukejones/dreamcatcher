class What < ActiveRecord::Base
  has_many :tags, :as => :noun
  has_many :dreams, :through => :tags, :source => :entry, :source_type => 'Dream'
  has_many :black_list_words
  
  validates :name,
            :presence => true,
            :uniqueness => true,
            :length => { :minimum => 3, :maximum => 20 }
 
  before_create :clean_name
  
  def self.clean(word)
    word = word.downcase.gsub(/^\W+|\W+$/, '') # remove white space from begin/end
    return word[/^\S+/] # drop everything after a white space
  end
  
  def clean_name
    self.name = self.class.clean(self.name)
  end
  
  # downcase & strip non alpha numeric chars at begin/end of tag
  def prep(what)
    self.class.clean(what)
  end    
end