import {
  Entity,
  PrimaryGeneratedColumn,
  Column,
  CreateDateColumn,
} from 'typeorm';

@Entity('firm_deposits')
export class FirmDeposit {
  @PrimaryGeneratedColumn()
  id: number;

  // positive = deposit, negative = withdrawal
  @Column({
    type: 'decimal',
    precision: 12,
    scale: 2,
    transformer: {
      to: (v: number) => v,
      from: (v: string) => parseFloat(v),
    },
  })
  amount: number;

  @Column({ type: 'date' })
  date: string;

  @Column({ nullable: true })
  note: string;

  @CreateDateColumn({ name: 'created_at' })
  createdAt: Date;
}
