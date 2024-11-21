**ЗАДАНИЕ 1**

*Проверьте код с помощью tflint и checkov*

**TFLINT**

на windows
**docker run —rm -v ${PWD}:/data -w /data ghcr.io/terraform-linters/tflint**

на линукс
**docker run —rm -v $(pwd):/tf bridgecrew/checkov —directory /tf**

*Перечислите, какие типы ошибок обнаружены в проекте (без дублей).*
11 issue(s) found:
привожу только уникальные типы ошибок :

-----
**Warning: Module source “git::<https://github.com/udjin10/yandex_compute_instance.git?ref=main>“ uses a default branch as ref (main) (terraform\_module\_pinned\_source)**

используется ветка main в git. потенциально опасно. лучше указывать хеш коммита

-----
**Warning: Missing version constraint for provider “template” in required\_providers (terraform\_required\_providers)**
не указана версия для провайдера! лучше всегда фиксировать версии!

-----
**Warning: [Fixable] variable “default\_cidr” is declared but not used (terraform\_unused\_declarations)**
дефолтное значение переменной обьявлено , но не использовано. остатки после переделки кода. убрать

-----
**Warning: [Fixable] variable “vpc\_prod” is declared but not used (terraform\_unused\_declarations)**
переменная задекларирована но не использованна. создавалась для выполнени дз в двух вариантах задачи. по факту не используется.убрать

-----
**CHECKOV**

**docker run —rm -v $(pwd):/tf bridgecrew/checkov —directory /tf**
или в винде
**docker run —rm -v ${PWD}:/tf bridgecrew/checkov —directory /tf**

-----
типы ошибок :

-----
**“Ensure Terraform module sources use a commit hash”**
использовать коммит хеш!

-----
**“Ensure Terraform module sources use a tag with a version number”**
вместо коммита и ветки мейн использовать конкретню версию!
## <a name="повторите демонстрацию лекции: настройте ydb, s3 bucket, yandex service account, права доступа и мигрируйте state проекта в s3 с блокировками. предоставьте скриншоты процесса в качестве ответа."></a>**Повторите демонстрацию лекции: настройте YDB, S3 bucket, yandex service account, права доступа и мигрируйте state проекта в S3 с блокировками. Предоставьте скриншоты процесса в качестве ответа.**
-----
**2Е ЗАДАНИЕ**
*Возьмите ваш GitHub-репозиторий с выполненным ДЗ 4 в ветке ‘terraform-04’ и сделайте из него ветку ‘terraform-05’.*

инициализируем Гит
**git init**
подключаем репозиторий
**git remote add origin [https://github.com/barmaq/terraform-05.git**](https://github.com/barmaq/terraform-05.git)**
**git add .**
**git commit -m “Initial commit”**

**git branch -M main
git push -u origin main**

-----
*настройте YDB, S3 bucket, yandex service account, права доступа и мигрируйте state проекта в S3 с блокировками. Предоставьте скриншоты процесса в качестве ответа.*

**terraform init —backend-config=”access\_key== —backend-config=”secret\_key=”**

добавил dynamodb\_endpoints, снова применил
**terraform init —backend-config=”access\_key=” —backend-config=”secret\_key=”**
Error: Backend configuration changed - это нормально. ведь стейт изменился. инициализируем с ключем -migrate-state
**terraform init —backend-config=”access\_key=” —backend-config=”secret\_key=”” -migrate-state**
![скриншот](./images/state_to_s3_bucket.png)
*Закоммитьте в ветку ‘terraform-05’ все изменения.*
**git add .
git commit -m “added backend block to providers - terraform-05”**

-----
*Откройте в проекте terraform console, а в другом окне из этой же директории попробуйте запустить terraform apply.
Пришлите ответ об ошибке доступа к state*

**terraform console**

1. ╷
1. │ Error: Error acquiring the state lock
1. │
1. │ Error message: operation error DynamoDB: PutItem, https response error StatusCode: 400, RequestID:
1. │ a733725d-7948-4cf9-9428-7b2d1f249eba, ConditionalCheckFailedException: Condition not satisfied
1. │ Lock Info:
1. │   ID:        76840236-7783-ca65-f46c-ffd4604405c3
1. │   Path:      barmaq-tfstate/terraform.tfstate
1. │   Operation: OperationTypeInvalid
1. │   Who:       ELECTRO\victorsh@LOGRUS
1. │   Version:   1.8.4
1. │   Created:   2024-11-20 14:39:19.5853771 +0000 UTC
1. │   Info:
1. │
1. │
1. │ Terraform acquires a state lock to protect the state from being written
1. │ by multiple users at the same time. Please resolve the issue above and try
1. │ again. For most commands, you can disable locking with the "-lock=false"
1. │ flag, but this is not recommended.

*Принудительно разблокируйте state. Пришлите команду и вывод*

terraform force-unlock 76840236-7783-ca65-f46c-ffd4604405c3

1. Do you really want to force-unlock?
1. `  `Terraform will remove the lock on the remote state.
1. `  `This will allow local Terraform commands to modify this state, even though it
1. `  `may still be in use. Only 'yes' will be accepted to confirm.

1. `  `Enter a value: yes

1. Terraform state has been successfully unlocked!

1. The state has been unlocked, and Terraform commands should now be able to
1. obtain a new lock on the remote state.
-----
**ЗАДАНИЕ 3**

*Сделайте в GitHub из ветки ‘terraform-05’ новую ветку ‘terraform-hotfix’.*

создаем ветку
**git branch terraform-hotfix**
переключаемся на нее
**git checkout terraform-hotfix**
отправляем содержимое
**git push -u origin terraform-hotfix**

*Проверье код с помощью tflint и checkov, исправьте все предупреждения и ошибки в ‘terraform-hotfix’, сделайте коммит.*

**docker run —rm -v ${PWD}:/data -w /data ghcr.io/terraform-linters/tflint**

исправил ошибки :
переменные **vpc\_name** и **vpc\_prod** не используются но обьявлены - остатки заданий. закомментил

фиксируем версии через указание конкретной версии или через шехкомиита в случае модулей
пример версии через хеш коммит
**source = “git::<https://github.com/udjin10/yandex_compute_instance.git?ref=0049a0c47c805c2552e16f7bca2581a7feae0f14>“**

удаляем неиспользуемые переменные

применяем изменения ( изменились модули )

**terraform init —backend-config=”access\_key= —backend-config=”secret\_key=”” -migrate-state**

делаем повторную проверку - проблем нет.

проверяем при помощи chekov
**docker run —rm -v ${PWD}:/tf bridgecrew/checkov —directory /tf**
тут вообще ошибок не было

делаем коммит:

**git add .
git commit -m “исправления после tflint и checkov “
git push origin terraform-hotfix**

*Откройте новый pull request ‘terraform-hotfix’ —> ‘terraform-05’*

выбрать ветку **terraform-hotfix**
выбрать **Compare & pull request**
указать заголовок и комментарий

*Пришлите ссылку на PR для ревью*
<https://github.com/barmaq/terraform-05/pull/1#issue-2679078720>

-----
**ЗАДАНИЕ 4**

*Напишите переменные с валидацией и протестируйте их, заполнив default верными и неверными значениями. Предоставьте скриншоты проверок из terraform console.*

\*type=string, description=”ip-адрес” — проверка, что значение переменной содержит верный IP-адрес с помощью функций cidrhost() или regex(). Тесты: “192.168.0.1” и “1920.1680.0.1”;

переменные в **main.tf** :

через **cidrhost**

**cidrhost()** напрямую не подходит для наших целей - он нужен чтобы узнать ip используя подсеть и номер хоста в этой подсети.и ожидает ввода с этими данными.
мы можем добиться нужного результата используя полную маску **/32** и первый хост ( **0** )
**can(cidrhost(join(“/“, [var.ip\_address, “32”]), 0))**

для тестов из консоли
**cidrhost(“192.168.0.1/32”, 0)
cidrhost(“1920.1680.0.1/32”, 0)**

онако в самой консоли мы присвоить значения переменной не можем, поэтому вносим их в **main.tf**

-----
вариант через **regex**
**can(regex(“^((25[0-5]|(2[0-4]|1\d|[1-9]|)\d).?\b){4}$”, var.ip\_address))**

проверка :  
![скриншот](./images/validate1.png)
![скриншот](./images/validate2.png)

-----
*type=list(string), description=”список ip-адресов” — проверка, что все адреса верны. Тесты: [“192.168.0.1”, “1.1.1.1”, “127.0.0.1”] и [“192.168.0.1”, “1.1.1.1”, “1270.0.0.1”].\**

для првоерки списка собираем на примере regex
**alltrue([for ip in var.ip\_addresses : , ip))])**

-----
**задание 5**

переменные в **main.tf** :

*Напишите переменные с валидацией:*
*type=string, description=”любая строка” — проверка, что строка не содержит символов верхнего регистра;*

тут решается при помощи **regex** , учел латинский + русский
итоговое условие
**regex(“^[^A-ZА-ЯЁ]\*$”, var.low\_case)**

*Напишите переменные с валидацией:
type=object — проверка, что одно из значений равно true, а второе false, т. е. не допускается false false и true true:*

а вот тут мы делаем через операцию сравнения. у нас только два значения переменной **true** и **false** , соответсвенно
**Dunkan != Connor**
итоговое условие
**var.in\_the\_end\_there\_can\_be\_only\_one.Dunkan != var.in\_the\_end\_there\_can\_be\_only\_one.Connor**

[скриншот]: Aspose.Words.5a0f5b34-2347-4bb9-b6dd-24496ff49a15.001.png
