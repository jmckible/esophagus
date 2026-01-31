import Cookies from 'js-cookie'

const timeZone = Intl.DateTimeFormat().resolvedOptions().timeZone
Cookies.set('time_zone', timeZone, {expires: 365, path: '/'})
