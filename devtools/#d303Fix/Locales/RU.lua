--[[
	d303Fix v0.9 by DRACULA, RU translation by tasquer
	Released under to public domain - http://en.wikipedia.org/wiki/Public_Domain
]]

d303Fix.Strings = {
	Header			= "[|cff00ff00d303Fix|r] ",
	Init			= "Загружен с датой и временем: %s.\n" .. 
"Введите |cff00ff00/dtis help|r или |cff00ff00/dtss help|r для получения дополнительной информации по командам.",
	NoFn			= "Функция \"%s\" недоступна.",
	OsRedeclared	= "Объект «os» уже определён, заменяем его.",
	
	ItemShop = {
		On			= "Для определения времени будет использоваться Магазин.",
		Off			= "Магазин не будет использоваться для определения времени.",
		Offset		= "Поправка к часовому поясу установлена на %d часа(-ов).",
		Attempt		= "Попытка извлечь время из Магазина.",
		Success		= "Установлено время %s с прибавкой %d ч. с помощью Магазина вещей: \"%s\".",
		Fail		= "Попытка извлечь время из Магазина не удалась. Осталось %d попыток.",
		Help		= "Команды касательно определения времени с помощью Магазина:\n" .. 
"- |cff00ff00/dtis help|r - показ справки.\n" .. 
"- |cff00ff00/dtis off|r - отключить возможность определять время с помощью Магазина.\n" .. 
"- |cff00ff00/dtis on|r - включить возможность определять время с помощью Магазина.\n" .. 
"- |cff00ff00/dtis [час]|r - установить поправку к часовому поясу.\n" .. 
"- |cff00ff00/dtis|r - сбросить часы.",
	},
	
	ScreenShot = {
		On			= "Для определения времени будет использоваться Снимок экрана.",
		Off			= "Скриншот не будет использоваться для определения времени.",
		OnFail		= "Screenshot will be taken to set date and time when ItemShop probing fails: ",
		Auto		= "Для определения времени при каждом входе в игру будет делаться снимок экрана: ",
		Yes			= "да.",
		No			= "нет.",
		Attempt		= "Попытка определить время с помощью Скриншота.",
		Success		= "Установлено время %s с помощью Скриншота.",
		Help		= "Команды касательно определения времени с помощью Снимка экрана:\n" .. 
"- |cff00ff00/dtss help|r - показ справки.\n" .. 
"- |cff00ff00/dtss off|r - отключить возможность определять время по имени файла Снимка экрана.\n" .. 
"- |cff00ff00/dtss on|r - включить возможность определять время по имени файла Снимка экрана.\n" .. 
"- |cff00ff00/dtss auto|r - включить/выключить возможность автоматически определять время при каждом входе.\n" .. 
"- |cff00ff00/dtss fail|r - Toggle ability to set time from Screenshot name when ItemShop probing fails." ..
"- |cff00ff00/dtss|r - Сделать снимок экрана.",
	},
		
	MonthsShort		= { "Янв", "Фев", "Мар", "Апр", "Май", "Июн", "Июл", "Авг", "Сен", "Окт", "Ноя", "Дек", },
	MonthsFull		= { "Январь", "Февраль", "Март", "Апрель", "Май", "Июнь", "Июль", "Август", "Сентябрь", "Октябрь", "Ноябрь", "Декабрь", },

	WeekDaysShort	= { "Вс", "Пон", "Вт", "Ср", "Чт", "Пт", "Суб", },
	WeekDaysFull	= { "Воскресенье", "Понедельник", "Вторник", "Среда", "Четверг", "Пятница", "Суббота", },
}
