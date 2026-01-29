import jstz from 'jstz'
import Cookies from 'js-cookie'

Cookies.set('time_zone', jstz.determine().name(), {expires: 365, path: '/'})
