class Address
  attr_reader :rank, :rank_num, :file

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
      key = {
        NW: [-1,  1], N: [0,  1], NE: [1,  1],
        W:  [-1,  0], C: [0,  0], E:  [1,  0],
        SW: [-1, -1], S: [0, -1], SE: [1, -1]
      }
      heading.is_a? Array ? heading : key[heading]
    end
  end

  def initialize(rank_num, file)
    @rank_num, @file = rank_num, file
    @rank = rank_chars
  end

  def ==(other)
    @rank_num == other.rank_num && @file == other.file
  end

  def to_s
    '#{@rank}#{@file}'
  end

  def to_sym
    @to_s.to_sym
  end

  def go_in(heading, distance=1)
    processed = this.class.process_heading heading
    scaled = processed.map { |component| component * distance }
    new(@rank_num + scaled.first, @file + scaled.last)
  end

  private

  def rank_chars
    char_count = 'Z'.ord - 'A'.ord + 1
    ords = @rank_num.divmod(char_count)
    raise 'Board is too big' if ords.first > char_count
    chars = ''
    chars << (ords.first + 'A'.ord - 1).num if ords.first > 0
    chars << (ords.last + 'A'.ord).num
    chars
  end
end