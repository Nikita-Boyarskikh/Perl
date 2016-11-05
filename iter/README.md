Домашнее задание Iterator
=========================

Требуется написать классы итераторов, которые отзываются на методы `next()` и `all()`.

`next()` возвращает пару `($val, 0)`, если очередное значение доступно, и `(undef, 1)`, если значения кончились.

`all()` возвращает ссылку на массив всех оставшихся элементов.

Типы итераторов
---------------

Нужно реализовать 4 типа таких итераторов. Подробно их интерфейс можно изучить по коду.

### Local::Iterator::Array

Итерируется по массиву.

### Local::Iterator::File

Итерируется по строкам файла (без переносов строк). Может быть инстанцирован как именем файла, так и _манипулятором_ (filehandle).

### Local::Iterator::Aggregator

Итерируется по элементам другого итератора, возвращая каждый раз порции из N элементов (или меньше, вплоть до одного, если значений не хватает).

### Local::Iterator::Concater

Итерируется последовательно по элементам других итераторов.

Интервалы (дополнительно задание)
---------------------------------

### Local::Iterator::Interval

Возвращает в заданном промежутке с заданным шагом временные интервалы заданной длины. Для указания времени используется `DateTime`, для указания длительности — `DateTime::Duration`, а возвращаемые интервалы — объекты `Local::Interval` с методами `from` и `to`.

Еще идеи для дополнительных заданий
-----------------------------------

* Mapper — итерируется по другому итератору, возвращая результат применения к каждому элементу функции-преобразователя (аналог `map`).
* Filter — итерируется по другому итератору, возвращая только элементы, для которых функция-фильтр вернула истинное значений (аналог `grep`).
* Mixer — итерируется по множеству итераторов, возвращая поочередно значение из очередного непустого.