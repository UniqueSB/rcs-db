require_relative 'single_evidence'

module RCS
module ChatProcessing
  extend SingleEvidence

  def type
    :chat
  end
end # ChatProcessing

module ChatskypeProcessing
  extend SingleEvidence

  def type
    :chat
  end
end # ChatskypeProcessing

end # RCS
