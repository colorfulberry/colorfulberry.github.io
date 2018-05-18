---
layout: post
title: schedule design
categories: [js error]
tags: [js]
comments: true
description: '定时任务数据库设计'
---


# shcedule db design
```
# This is only set for availability
t.integer day_id, # if none means set a temp hour, values from [null, 1,2,3,4,5,6]

# This is only set for none availability
t.integer :state, default: 0, null: false # available or unavailable, for with day_id is available

# When they set their end time it might possibly be on depending on their timezone.
#
# For a one off notification the start_date and end_date will be a UTC date with the exact date and time they will be
# available or unavailable.
# with a day_id time start from 1970-01-03 ~ 1970-01-10, 3 left for the time offset day
t.datetime :start_date, null: false
t.datetime :end_date, null: false

```


# query
```
scope :available_for_notification, -> {
  now = Time.zone.now.utc
  week_with_day = 4 + now.wday
  data = {
    available: TutorNotificationHour.states[:available],
    unavailable: TutorNotificationHour.states[:unavailable],
    now: now,
    now_recurring: now.change(year: 1970, month: 1, day: week_with_day),
    end_week_day_recurring: now.change(year: 1970, month: 1, day: 3),
    wday: now.wday
  }

  find_by_sql [
    "SELECT DISTINCT tutors.* FROM tutors
    INNER JOIN tutor_notification_hours AS available_period ON available_period.tutor_id = tutors.id
    LEFT OUTER JOIN tutor_notification_hours AS unavailable_period ON unavailable_period.tutor_id = tutors.id
      AND unavailable_period.state = :unavailable AND :now between unavailable_period.start_date and unavailable_period.end_date
    WHERE (
      (:now_recurring between available_period.start_date and available_period.end_date)
        OR (:wday = 6 AND :end_week_day_recurring between available_period.start_date and available_period.end_date)
          OR (:now between available_period.start_date and available_period.end_date AND available_period.state = :available)
    )
    AND unavailable_period.id IS NULL",
    data
  ]
}
```
