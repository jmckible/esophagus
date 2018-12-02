import jstz from 'jstz'
import Cookie from 'js.cookie'

Cookie.set('time_zone', jstz.determine().name(), {expires: 365, path: '/'})
