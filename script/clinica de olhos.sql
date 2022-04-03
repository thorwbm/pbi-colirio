CREATE TABLE [dm_paciente] (
  [id] int PRIMARY KEY NOT NULL,
  [data_nascimento] DATEtime NOT NULL,
  [data_registro] DATEtime NOT NULL
)
GO



CREATE TABLE [dm_atividade] (
  [id] int IDENTITY(1,1) PRIMARY KEY NOT NULL,
  [nome] varchar(200) NOT NULL
)
GO

CREATE TABLE [ft_paciente_atividade] (
  [id] int IDENTITY(1,1) PRIMARY KEY NOT NULL,
  [paciente_id] int NOT NULL,
  [atividade_id] int NOT NULL,
  [data_registro] DATEtime NOT NULL
)
GO

ALTER TABLE [ft_paciente_atividade] ADD FOREIGN KEY ([atividade_id]) REFERENCES [dm_atividade] ([id])
GO

ALTER TABLE [ft_paciente_atividade] ADD FOREIGN KEY ([paciente_id]) REFERENCES [dm_paciente] ([id])
GO

EXEC sp_addextendedproperty
@name = N'Table_Description',
@value = 'Tabela de paciente',
@level0type = N'Schema', @level0name = 'dbo',
@level1type = N'Table',  @level1name = 'dm_paciente';
GO

EXEC sp_addextendedproperty
@name = N'Column_Description',
@value = 'data de nascimento',
@level0type = N'Schema', @level0name = 'dbo',
@level1type = N'Table',  @level1name = 'dm_paciente',
@level2type = N'Column', @level2name = 'data_nascimento';
GO

EXEC sp_addextendedproperty
@name = N'Column_Description',
@value = 'data de registro',
@level0type = N'Schema', @level0name = 'dbo',
@level1type = N'Table',  @level1name = 'dm_paciente',
@level2type = N'Column', @level2name = 'data_registro';
GO



EXEC sp_addextendedproperty
@name = N'Column_Description',
@value = 'FK do paciente',
@level0type = N'Schema', @level0name = 'dbo',
@level1type = N'Table',  @level1name = 'ultima_atividade_paciente',
@level2type = N'Column', @level2name = 'paciente_id';
GO

EXEC sp_addextendedproperty
@name = N'Column_Description',
@value = 'FK da atividade',
@level0type = N'Schema', @level0name = 'dbo',
@level1type = N'Table',  @level1name = 'ultima_atividade_paciente',
@level2type = N'Column', @level2name = 'atividade_id';
GO

EXEC sp_addextendedproperty
@name = N'Column_Description',
@value = 'data de registro',
@level0type = N'Schema', @level0name = 'dbo',
@level1type = N'Table',  @level1name = 'ultima_atividade_paciente',
@level2type = N'Column', @level2name = 'data_ultimo_registro';
GO

EXEC sp_addextendedproperty
@name = N'Table_Description',
@value = 'Tabela de atividades monitoradas',
@level0type = N'Schema', @level0name = 'dbo',
@level1type = N'Table',  @level1name = 'dm_atividade';
GO

EXEC sp_addextendedproperty
@name = N'Column_Description',
@value = 'nome da atividade',
@level0type = N'Schema', @level0name = 'dbo',
@level1type = N'Table',  @level1name = 'dm_atividade',
@level2type = N'Column', @level2name = 'nome';
GO

EXEC sp_addextendedproperty
@name = N'Table_Description',
@value = 'Tabela de fato',
@level0type = N'Schema', @level0name = 'dbo',
@level1type = N'Table',  @level1name = 'ft_paciente_atividade';
GO

EXEC sp_addextendedproperty
@name = N'Column_Description',
@value = 'FK chave estrangeira da tabela paciente',
@level0type = N'Schema', @level0name = 'dbo',
@level1type = N'Table',  @level1name = 'ft_paciente_atividade',
@level2type = N'Column', @level2name = 'paciente_id';
GO

EXEC sp_addextendedproperty
@name = N'Column_Description',
@value = 'FK chave estrangeira da tabela atividade',
@level0type = N'Schema', @level0name = 'dbo',
@level1type = N'Table',  @level1name = 'ft_paciente_atividade',
@level2type = N'Column', @level2name = 'atividade_id';
GO

EXEC sp_addextendedproperty
@name = N'Column_Description',
@value = 'data de registro',
@level0type = N'Schema', @level0name = 'dbo',
@level1type = N'Table',  @level1name = 'ft_paciente_atividade',
@level2type = N'Column', @level2name = 'data_registro';
GO


--##############################################################################
insert into dw_colirio..dm_paciente
select  cd_paciente as paciente_id,  
       cast(substring(dt_nascimento,7,4) + '-' + substring(dt_nascimento,4,2) + '-'   + substring(dt_nascimento,1,2) as date) as data_nascimento, 
       dt_registro = min(cast(substring(dt_registro,7,4) + '-' + substring(dt_registro,4,2) + '-'   + substring(dt_registro,1,2) + ' '   + right(dt_registro,8) as datetime)) 
from tmp_paciente
 group by cd_paciente,  
       cast(substring(dt_nascimento,7,4) + '-' + substring(dt_nascimento,4,2) + '-'   + substring(dt_nascimento,1,2) as date)


insert into dw_colirio..dm_atividade (nome)
select nome = 'INCLUSÃO'
insert into dw_colirio..dm_atividade (nome)
select nome = 'ACOMPANHAMENTO'
insert into dw_colirio..dm_atividade (nome)
select nome = 'REAVALIAÇÃO'
insert into dw_colirio..dm_atividade (nome)
select nome = 'ENTREGA DE COLIRIO'


--####### acompanhamento 
insert into dw_colirio..ft_paciente_atividade (paciente_id, atividade_id, data_registro)
select cd_paciente as paciente_id, atividade_id = 2, data_registro = cast(substring(dt_registro,7,4) + '-' + substring(dt_registro,4,2) + '-'   + substring(dt_registro,1,2) + ' '   + right(dt_registro,8) as datetime)
  from tmp_acompanhamento tmp join dw_colirio..dm_paciente pac on (pac.id = tmp.cd_paciente)
 order by 1
------------------------  


--####### colirio 
insert into dw_colirio..ft_paciente_atividade (paciente_id, atividade_id, data_registro)
select distinct cd_paciente as paciente_id, atividade_id = 4, data_registro = cast(substring(dt_registro,7,4) + '-' + substring(dt_registro,4,2) + '-'   + substring(dt_registro,1,2) + ' '   + right(dt_registro,8) as datetime)
  from tmp_entrega_colirio tmp join dw_colirio..dm_paciente pac on (pac.id = tmp.cd_paciente)
 order by 1
------------------------  





--####### reavaliacao 
insert into dw_colirio..ft_paciente_atividade (paciente_id, atividade_id, data_registro)
select distinct cd_paciente as paciente_id, atividade_id = 3, data_registro = cast(substring(dt_registro,7,4) + '-' + substring(dt_registro,4,2) + '-'   + substring(dt_registro,1,2) + ' '   + right(dt_registro,8) as datetime)
  from tmp_reavaliado tmp join dw_colirio..dm_paciente pac on (pac.id = tmp.cd_paciente)
 order by 1
------------------------  



--####### inclusao 
insert into dw_colirio..ft_paciente_atividade (paciente_id, atividade_id, data_registro)
select distinct cd_paciente as paciente_id, atividade_id = 1, data_registro = cast(substring(dt_registro,7,4) + '-' + substring(dt_registro,4,2) + '-'   + substring(dt_registro,1,2) + ' '   + right(dt_registro,8) as datetime)
  from tmp_incluido tmp join dw_colirio..dm_paciente pac on (pac.id = tmp.cd_paciente)
 order by 1
------------------------  
