require ENV['TM_SUPPORT_PATH'] + '/lib/exit_codes'
require ENV['TM_SUPPORT_PATH'] + '/lib/current_word'
require 'time'

module TimeTracker
  
  def self.new
    line = '- ${1} [${2:' + self.getnow + '}]'
    TextMate.exit_insert_snippet(line)
  end
  
  def self.now
    TextMate.exit_insert_snippet(self.getnow)
  end
  
  def self.getnow
    t = Time.now
    now = t.round(5*60).strftime("%I:%M%p").gsub(/^0/,'').chop().downcase()
    now += '-' if Word.current_word('-^') != '-'
    now
  end
  
  def self.tally
    doc = self.cleandoc($stdin.read())
    poc = doc.split('#').map { |i| i.split(/\n/) }    
    total_hours = 0.0
    
    for set in poc      
      next if set.empty?
      
      set_hours = 0.0
      set.delete_if { |line| line.strip().empty? }
      
      set[0] = '#' + set[0]
    
      times = set.map! { |line|
        if line.match(/^-.*\[.*?\].*?/)
          hours = 0.0

          line.match('\[(.*)\]')[1].split(',').map! { |i| 
            if i.match(/\-/)
              hours += self.tally_range(i)
            elsif i.match(/\./)
              hours += self.tally_static(i)
            end
          };

          set_hours += hours
          line = line.strip().gsub(/(\(.*\))$/,'').strip() + ' (' + hours.to_s + ')'
        end
        line
      }.push(["  ------------------\n  project: " + set_hours.to_s,' '])

      total_hours += set_hours
    end
    
    poc.push(["====================\n  total: " + total_hours.to_s])
    TextMate.exit_replace_document(poc.flatten().join("\n").strip())
  end
  
  def self.tally_static(time)
    # janky -FIX
    time.to_f
  end
  
  def self.tally_range(range)
    time = 0.0
    
    t = range.split('-')
    return time if t[0] == nil || t[1] == nil

    # there has to be a more elegant way of handling this...
    if t[0].split(':')[0].to_f > t[1].split(':')[0].to_f # first is greater than second
       t[0] += 'a' if !t[0].strip().match(/a$/) && t[0].split(':')[0].to_i < 12
       t[0] += 'p' if !t[0].strip().match(/a$/) && t[0].split(':')[0].to_i >= 12
       t[1] += 'p' if !t[1].strip().match(/p$/)        
     elsif t[0].strip().match(/(a|p)$/) && !t[1].strip().match(/(a|p)$/) # first designates a/p
       t[1] += t[1].split(':')[0].to_i < 12 ? t[0][/(a|p)$/] : (t[0].strip().match(/(a)$/) ? 'p' : 'a')   
     elsif t[1].strip().match(/(a|p)$/) && !t[0].strip().match(/(a|p)$/) # second designates a/p
       t[0] += t[1].split(':')[0].to_i < 12 ? t[1][/(a|p)$/] : (t[1].strip().match(/(a)$/) ? 'p' : 'a')
     elsif !t[0].strip().match(/(a|p)$/) && !t[1].strip().match(/(a|p)$/) # nobody designates a/p
       t[0] += 'a'
       t[1] += (t[1].split(':')[0].to_i < 12 ? 'a' : 'p')
     end

    ts = Time.parse(t[0].gsub(/(a|p)/,' \1m'));
    te = Time.parse(t[1].gsub(/(a|p)/,' \1m'));             

    timestart = ((ts.hour.to_f*3600)+3600)+(ts.min.to_f)*60
    timeend = ((te.hour.to_f*3600)+3600)+(te.min.to_f)*60
    time += (((((timeend-timestart)/60.0)/15.0).round)*15.0)/60.0
    
    time = 0.25 if time == 0
    return time
  end
  
  def self.clean
    doc = $stdin.read()
    TextMate.exit_replace_document(self.cleandoc(doc))
  end
  
  def self.cleandoc(doc)
    poc = doc.split(/\n/).map { |line|      
      line = '' if line.match(/^(==+|  --+|  project:|  total:).*?$/)
      line = line.rstrip().gsub(/(\(.*\))$/,'')
      line
    }
    poc.join("\n").strip().gsub(/\n\n\n/,"\n")
  end
  
end

# mod to time class courtesy of:
# http://stackoverflow.com/questions/449271/how-to-round-a-time-down-to-the-nearest-15-minutes-in-ruby
class Time
  def round(seconds = 60)
    Time.at((self.to_f / seconds).round * seconds)
  end

  def floor(seconds = 60)
    Time.at((self.to_f / seconds).floor * seconds)
  end
end