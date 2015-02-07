class Hash
  # rubocop:disable LineLength
  def to_path_hash(separator = nil)
    paths.map do |pathname|
      {
        path: separator ? pathname[0..-2].join(separator) : File.join(pathname[0..-2]),
        content: pathname.last
      }
    end
  end
  # rubocop:enable LineLength

  private

  def paths
    map do |path, opts|
      sub_path = opts.respond_to?(:paths) ? opts.paths : opts.to_s
      [path.to_s, sub_path].flatten
    end
  end
end
