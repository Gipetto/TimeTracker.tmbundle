require ENV['TM_SUPPORT_PATH'] + '/lib/exit_codes'
require ENV['TM_SUPPORT_PATH'] + '/lib/current_word'
require 'time'

module TimeTracker
  
  def self.new
    line = '- ${1} [${2}]'
    TextMate.exit_insert_snippet(line)
  end
  
  def self.now
    t = Time.now
    minutes_rounded = ((t.strftime("%M").to_f/5).round()*5).to_s;
    now = t.strftime("%I").gsub(/^0/,'') + ":" + minutes_rounded + t.strftime("%p").chop().downcase()
    now += '-' if Word.current_word('-^') != '-'
        
    TextMate.exit_insert_snippet(now)
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
      
      set.map! { |line|
        if line.match(/^- /)
          hours = 0.0
          
          times = line.match('\[(.*)\]')[1].split(',').map! { |i| 
            t = i.split('-')
            next if t[0] == nil || t[1] == nil
            
            # there has to be a more elegant way of handling this...
            if t[0].split(':')[0].to_f > t[1].split(':')[0].to_f
              # handle crossing noon or midnight
              t[0] += 'a' if !t[0].strip().match(/a$/)
              t[1] += 'p' if !t[1].strip().match(/p$/)
            elsif t[0].strip().match(/(a|p)/) && !t[1].strip().match(/(a|p)/)
              t[1] += t[0][/(a|p)$/]            
            elsif t[1].strip().match(/(a|p)/) && !t[0].strip().match(/(a|p)/)
              t[0] += t[1][/(a|p)$/]
            elsif !t[0].strip().match(/(a|p)/) && !t[1].strip().match(/(a|p)/)
              t[0] += 'a'
              t[1] += 'a'
            end
            
            ts = Time.parse(t[0].gsub(/(a|p)/,' \1m'));
            te = Time.parse(t[1].gsub(/(a|p)/,' \1m'));             

            timestart = ((ts.hour.to_f*3600)+3600)+((((ts.min.to_f/15).round)*15)*60)
            timeend = ((te.hour.to_f*3600)+3600)+((((te.min.to_f/15).round)*15)*60)
            
            hours += ((timeend-timestart)/60)/60
            hours = 0.25 if hours == 0
            hours
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