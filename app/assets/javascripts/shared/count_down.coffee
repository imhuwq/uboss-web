$ ->

  if $('#clock_refund')
    $this = $('#clock_refund')
    html = '<span class="times_day"><span>00</span></span> 天'+
      '<span class="times_hour"><span>00</span></span> 时' +
      '<span class="times_minute"><span>00</span></span> 分' +
      '<span class="times_second"><span>00</span></span> 秒'
    $this.html(html)

    time_day    = $this.find(".times_day")
    time_hour   = $this.find(".times_hour")
    time_minute = $this.find(".times_minute")
    time_second = $this.find(".times_second")

    time_end = $this.data('endtime')
    time_end = (new Date(time_end)).getTime()

    count_down = () ->
      time_now = (new Date()).getTime()  #获取当前时间
      time_distance = time_end - time_now

      if time_distance >= 0
        int_day = Math.floor(time_distance/86400000)
        time_distance -= int_day * 86400000

        int_hour = Math.floor(time_distance/3600000)
        time_distance -= int_hour * 3600000

        int_minute = Math.floor(time_distance/60000)
        time_distance -= int_minute * 60000

        int_second = Math.floor(time_distance/1000)

        # 判断小时小于10时，前面加0进行占位
        if(int_hour < 10)
           int_hour = "0" + int_hour

        if(int_minute < 10)
          int_minute = "0" + int_minute

        if(int_second < 10)
          int_second = "0" + int_second

        time_day.text(int_day)
        time_hour.text(int_hour)
        time_minute.text(int_minute)
        time_second.text(int_second)

        setTimeout () ->
          count_down()
        , 1000

      else
        $this.html('')

    count_down()
