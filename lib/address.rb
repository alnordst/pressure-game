class Address
  attr_reader :rank, :file, :file_num

  class << self
    def rotate(headings)
      headings.map do |heading|
        rotations_of process_heading(heading)
      end.flatten(1).uniq
    end

    def rotations_of((x, y))
      [[x, y], [-x, -y], [-y, x], [y, -x]].uniq
    end

    def process_heading(heading)
      sym = heading.upcase.to_sym
      key = {
        NW: [-1, -1], N: [-1, 0], NE: [-1, 1],
        W:  [ 0, -1], C: [ 0, 0], E:  [ 0, 1],
        SW: [ 1, -1], S: [ 1, 0], SE: [ 1, 1]
      }
      key[sym]
    rescue
      heading
    end
  end

  def initialize(rank, file_num)
    @rank, @file_num = rank, file_num
    @file = file_chars
  end

  def ==(other)
    @rank == other.rank && @file_num == other.file_num
  end

  def to_s
    "#{@file}#{@rank}"
  end

  def to_sym
    to_s&.to_sym
  end

  def go_in(heading, distance=1)
    processed = Address.process_heading heading
    scaled = processed.map { |component| component * distance }
    Address.new(@rank - scaled.first, @file_num + scaled.last)
  end

  private

  def file_chars
    char_count = 'Z'.ord - 'A'.ord + 1
    ords = @file_num.divmod(char_count)
    raise 'Board is too big' if ords.first > char_count
    chars = ''
    chars << (ords.first + 'A'.ord - 2).chr if ords.first > 0
    chars << (ords.last + 'A'.ord - 1).chr
    chars
  end
end