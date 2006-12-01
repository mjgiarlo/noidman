class Noid
  attr_reader :noid_id
  
  require 'fileutils'
  require 'bdb'

  @@noid_cmd = '/usr/bin/noid'
  @@noid_dir = '/var/www/localhost/htdocs/nd/'

  def initialize( noid_id= '', minter_dir='prod' )
    @noid_id = noid_id
    FileUtils::chdir @@noid_dir + minter_dir
  end

  def mint
   @noid_id = %x( #@@noid_cmd mint 1 ).scan(/^id:\s+(.+)/)
  end

  def bind( cmd, url )
    %x( #@@noid_cmd bind #{cmd} #@noid_id location #{url} ).scan(/^Status:\s+(.+)/)
  end

  def get( noid )
    %x( #@@noid_cmd get #{noid} location ).chomp
  end

  def get_metadata( noid )
    %x( #@@noid_cmd get #{noid} metadata ).chomp
  end

  def get_support( noid )
    %x( #@@noid_cmd get #{noid} support ).chomp
  end

  def get_all( status='bound' )
    minted_noids = {}
    noid_db_records = BDB::Btree.open 'NOID/noid.bdb', nil, 'r', {}
    noid_db_records.each do |id, url|
      next if not id.match('^88435') or id.match(':/c$')
      if url.eql?('1')
        minted_noids[id.sub(/\t:\/h/, '')] = '' if not status.eql?('bound')
      else
        minted_noids[id.sub(/\tlocation/, '')] = url if status.eql?('bound') 
      end
    end
    minted_noids
  end

  def has_minted?( url )
    db = BDB::Btree.open 'NOID/noid.bdb', nil, 'r', {}
    db.has_value?( url )
  end

  def minted_by( url )
    db = BDB::Btree.open 'NOID/noid.bdb', nil, 'r', {}
    db.index( url ).sub(/\tlocation/, '') if db.has_value?( url )
  end


  def mint_and_bind( url )
    mint
    bind_new( url )
    @noid_id
  end

  def dump_stats
    @db_stats = {}
    db = BDB::Btree.open 'NOID/noid.bdb', nil, 'r', {}
    db.stat.each do |k, v|
      @db_stats.store k, v
    end
    db.close
    @db_stats
  end

  def dump_records
    @db_recs = {}
    db = BDB::Btree.open 'NOID/noid.bdb', nil, 'r', {}
    db.each do |k, v|
      @db_recs.store k, v
    end
    db.close
    @db_recs
  end

  def bind_new( url )
    bind( 'new', url )
  end

  def bind_replace( url )
    bind( 'replace', url )
  end
  
  def bind_purge( url='ignored' )
    bind( 'purge', url )
  end
end
